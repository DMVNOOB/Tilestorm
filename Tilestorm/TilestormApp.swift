import SwiftUI
import TileEngine

@main
struct TilestormApp: App {
    init() {
        GameFont.registerBundledFonts()
        // Load the ~173k-word dictionary off the main thread so the title screen appears immediately.
        Task.detached(priority: .userInitiated) { _ = WordList.enable }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
