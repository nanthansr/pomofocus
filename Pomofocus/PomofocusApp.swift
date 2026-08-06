import SwiftUI

@main
struct PomofocusApp: App {
    // AppKit owns the menu bar via NSStatusItem (see AppDelegate). This keeps
    // the icon reliably visible where SwiftUI's MenuBarExtra could get hidden.
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // No window and no Dock icon (LSUIElement). The Settings scene keeps
        // SwiftUI happy without showing anything on launch.
        Settings {
            EmptyView()
        }
    }
}
