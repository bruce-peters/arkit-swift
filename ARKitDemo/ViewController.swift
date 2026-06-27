import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    private var sceneView: ARSCNView!
    private var textView: UITextView!
    private var frameCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSceneView()
        setupTextView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard ARFaceTrackingConfiguration.isSupported else {
            textView.text = "Face tracking is not supported on this device.\nRequires iPhone X or later with TrueDepth camera."
            return
        }

        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    private func setupSceneView() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        view.addSubview(sceneView)
    }

    private func setupTextView() {
        let height = view.bounds.height * 0.45
        textView = UITextView(frame: CGRect(
            x: 0,
            y: view.bounds.height - height,
            width: view.bounds.width,
            height: height
        ))
        textView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        textView.textColor = .green
        textView.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.text = "Waiting for face tracking…"
        view.addSubview(textView)
    }
}

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        // Throttle display updates to ~30 fps
        frameCount += 1
        guard frameCount % 2 == 0 else { return }

        let shapes = faceAnchor.blendShapes
        var lines = ["BLEND SHAPES (\(shapes.count))\n" + String(repeating: "─", count: 36)]

        for key in shapes.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
            guard let value = shapes[key] else { continue }
            let f = value.floatValue
            let bar = String(repeating: "▓", count: Int(f * 15))
                .padding(toLength: 15, withPad: "░", startingAt: 0)
            let name = key.rawValue
                .replacingOccurrences(of: "blendShape1_", with: "")
                .padding(toLength: 28, withPad: " ", startingAt: 0)
            lines.append(String(format: "%@ %.3f %@", name, f, bar))
        }

        let text = lines.joined(separator: "\n")
        DispatchQueue.main.async { [weak self] in
            self?.textView.text = text
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARFaceAnchor else { return }
        DispatchQueue.main.async { [weak self] in
            self?.textView.text = "Face detected — tracking blend shapes…"
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.textView.text = "Session error: \(error.localizedDescription)"
        }
    }
}
