import Foundation
import ServiceManagement

/// Registers the app to start automatically when you log in.
///
/// Uses `SMAppService` (macOS 13+), the modern replacement for login-item
/// helpers. This only works from a real `.app` bundle; from `swift run` the
/// calls throw and are safely ignored.
enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func set(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Not fatal — e.g. running unbundled, or the user denied it.
        }
    }
}
