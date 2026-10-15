# arkit-swift

ARKitDemo is a minimal iPhone app that runs ARKit face tracking on the front
camera and shows a live readout of every ARKit face **blend shape** (eye blinks,
brow raises, jaw open and the rest). Each one is a value from 0 to 1 with a
text bar next to it.

## What it does

Everything is in two UIKit files. There is no storyboard and no SwiftUI.

- `ARKitDemo/AppDelegate.swift` creates the window and sets `ViewController` as
  its root.
- `ARKitDemo/ViewController.swift`:
  - Fills the screen with an `ARSCNView` running `ARFaceTrackingConfiguration`
    with light estimation. The session pauses when the view goes away.
  - Covers the bottom 45% of the screen with a green, monospaced, scrollable
    text panel.
  - On every second face-anchor update (about 30 updates a second), lists every
    `ARFaceAnchor.blendShapes` entry sorted by name. Each line shows the
    coefficient to three decimals and a 15-character `▓░` bar.
  - Shows "Face detected" when a face anchor first appears. If
    `ARFaceTrackingConfiguration.isSupported` is false, it shows a "not
    supported" message. Session errors also appear in the panel.

This repo is also embedded in
[word-level-gaze-target-detection](https://github.com/bruce-peters/word-level-gaze-target-detection)
as its `arkit-demo-swift` git submodule.

## Requirements

- A Mac with **Xcode 14 or newer**. The project file uses the Xcode 14.0 format
  (`objectVersion = 56`, `CreatedOnToolsVersion = 14.0`).
- An **iPhone running iOS 14.0 or later** that supports ARKit face tracking: one
  with a TrueDepth (Face ID) front camera. The target is iPhone-only and
  portrait-only.
- The iOS Simulator cannot run ARKit face tracking. You need a real device.
- An Apple ID added to Xcode for code signing. A free personal team works for
  running the app on your own phone.

## Run it

1. Clone the repo and open the project:
   ```bash
   git clone https://github.com/bruce-peters/arkit-swift.git
   open arkit-swift/ARKitDemo.xcodeproj
   ```
2. Select the **ARKitDemo** target, then go to **Signing & Capabilities**. Under
   **Team**, choose your own team. The project uses automatic signing and sets
   no team.
3. If Xcode says the bundle identifier `com.brucepeters.arkit-dev` is
   unavailable for your team, change it to something unique (for example
   `com.yourname.arkit-dev`).
4. Connect your iPhone, pick it as the run destination, and press **Run** (⌘R).
   On a new device you may also need to:
   - turn on **Developer Mode** (iOS 16 and later)
   - trust your developer certificate under Settings → General → VPN & Device
     Management
5. Allow camera access when asked. The usage string is in
   `ARKitDemo/Info.plist`. Point the front camera at your face, and the blend
   shape list starts updating.

These steps follow the project settings. They were not run here, because they
need macOS, Xcode and a device.

## CI

`.github/workflows/build.yml` runs on pushes and pull requests to `main`, and
can also be started by hand. On a `macos-14` runner it:

1. imports a signing certificate and provisioning profile from repository
   secrets
2. archives a Release build of the `ARKitDemo` scheme
3. exports a development-signed `ARKitDemo.ipa` as a workflow artifact, kept for
   14 days

It needs three repository secrets:

| Secret | Contents |
|---|---|
| `CERTIFICATE_P12` | base64 of the signing certificate `.p12` |
| `CERTIFICATE_PASSWORD` | password for that `.p12` |
| `PROVISIONING_PROFILE` | base64 of the `.mobileprovision` file |

Runs without these secrets fail at the certificate import step.

## Project structure

```
ARKitDemo.xcodeproj/   Xcode project + shared ARKitDemo scheme
ARKitDemo/
  AppDelegate.swift    app entry point, creates the window
  ViewController.swift ARSCNView face tracking + blend-shape text panel
  Info.plist           camera usage string, requires ARKit, portrait only
.github/workflows/
  build.yml            signed archive + .ipa artifact on macOS
```
