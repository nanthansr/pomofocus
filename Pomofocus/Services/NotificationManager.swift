import Foundation
import UserNotifications

/// Thin wrapper around macOS notifications.
///
/// Notifications only work from a real `.app` bundle. When the app is run
/// straight from the command line (`swift run`) there is no bundle, so we skip
/// everything to avoid crashing during development.
enum NotificationManager {
    private static var isBundledApp: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    static func requestAuthorization() {
        guard isBundledApp else { return }
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    static func notify(title: String, body: String) {
        guard isBundledApp else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
