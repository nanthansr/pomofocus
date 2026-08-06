import AppKit
import SwiftUI

/// Owns the menu bar presence using AppKit's `NSStatusItem`, which is the most
/// reliable way to keep an icon visible in the macOS menu bar. Clicking the
/// icon toggles a popover that hosts the existing SwiftUI control panel.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = SessionStore()
    private lazy var engine = PomodoroEngine(store: store)

    private var statusItem: NSStatusItem?
    private let popover = NSPopover()

    private let firstLaunchKey = "app.didShowFirstLaunchNotice"

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        showFirstLaunchNoticeIfNeeded()
    }

    // MARK: - Menu bar icon

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = item.button {
            // Host the SwiftUI ring inside the status button so it redraws as
            // the session progresses.
            let ring = NSHostingView(rootView: MenuBarRingView(engine: engine))
            ring.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(ring)
            NSLayoutConstraint.activate([
                ring.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                ring.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                ring.widthAnchor.constraint(equalToConstant: 18),
                ring.heightAnchor.constraint(equalToConstant: 18)
            ])

            button.action = #selector(togglePopover)
            button.target = self
            button.toolTip = "Pomofocus"
        }

        statusItem = item
    }

    // MARK: - Popover panel

    private func setupPopover() {
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuContentView(engine: engine, store: store)
        )
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Activate so text fields inside the popover can accept focus.
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - First launch hint

    private func showFirstLaunchNoticeIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: firstLaunchKey) else { return }
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
        NotificationManager.notify(
            title: "Pomofocus is running",
            body: "Look for the ring icon in your menu bar (top right)."
        )
    }
}
