# Build notes

- iOS deployment target: 18.0
- Device family: iPhone only
- SwiftUI modular source tree is synchronized by the Xcode project.
- Camera, location, microphone, photos and motion usage descriptions are present in generated Info.plist build settings.
- `swiftc -parse` passes for every Swift source file in this package.
- A full iOS SDK build must still be run on macOS/Xcode because the packaging environment does not include Apple SDKs or xcodebuild.

Recommended after replacing a previous version:

1. Open this `ATLAS.xcodeproj` directly.
2. Product → Clean Build Folder.
3. Select your physical iPhone.
4. Run with Command + R.
5. Accept camera permission when ATLAS first opens the scanner.
