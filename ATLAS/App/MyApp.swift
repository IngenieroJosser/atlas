import SwiftUI

@main
struct MyApp: App {
    init() {
        AtlasFontRegistry.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            AtlasRootView()
        }
    }
}
