import SwiftUI

@main
struct MyApp: App {
    @StateObject private var store = AtlasAppStore.shared

    init() {
        AtlasFontRegistry.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            AtlasRootView()
                .environmentObject(store)
        }
    }
}
