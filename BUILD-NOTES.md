# ATLAS v10 build notes

## What changed

- Rebuilt the visual language around an editorial, section-driven mobile composition.
- Preserved the ATLAS v9 light color palette.
- Reworked the Home screen into four numbered sections with hero, live preview, asset selection, intelligence actions and a 4-step product flow.
- Reworked Assets and Changes index screens.
- Updated shared components and typography so the visual change propagates across the whole app.
- Preserved the real AVFoundation camera flow from v9.1.
- Preserved AppIcon, camera permission text and iOS 18 deployment target.

## Validation performed

- Swift syntax parse passed for every `.swift` file.
- 23 Swift files found.
- 40 AtlasRoute cases found and all 40 are handled by ContentView.
- No duplicate declared type names detected.
- AtlasCamera imports Combine and remains ObservableObject-compatible.
- NSCameraUsageDescription remains configured in the Xcode project.

## Xcode

Open `ATLAS.xcodeproj`, then use Product > Clean Build Folder before the first run if replacing an older version.
