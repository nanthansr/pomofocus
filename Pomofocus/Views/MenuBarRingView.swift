import SwiftUI

/// Wraps `ProgressRingView` for use inside the AppKit status item. It observes
/// the engine directly so the menu bar icon redraws as the session runs.
struct MenuBarRingView: View {
    @ObservedObject var engine: PomodoroEngine

    var body: some View {
        ProgressRingView(
            progress: engine.progress,
            phase: engine.phase,
            state: engine.state
        )
        .frame(width: 18, height: 18)
    }
}
