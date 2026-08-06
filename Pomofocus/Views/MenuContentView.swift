import AppKit
import SwiftUI

/// The dropdown panel shown when the menu bar ring is clicked. It swaps between
/// modes based on the engine's phase and state: set an intent, run a focus
/// block, capture thoughts, rest, and see your streak.
struct MenuContentView: View {
    @ObservedObject var engine: PomodoroEngine
    @ObservedObject var store: SessionStore

    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content

            Divider()

            footer

            Divider()

            settingsRow
        }
        .padding()
        .frame(width: 240)
    }

    // MARK: - Mode switching

    @ViewBuilder
    private var content: some View {
        switch (engine.state, engine.phase) {
        case (.idle, _):
            IntentInputView(engine: engine)

        case (.running, .work), (.paused, .work):
            activeFocus

        case (.running, _), (.paused, _):
            activeBreak

        case (.completed, .work):
            VStack(alignment: .leading, spacing: 12) {
                Text("Focus complete")
                    .font(.headline)
                RestRitualView(engine: engine)
                Button("Start another focus") { engine.reset() }
                    .font(.caption)
            }

        case (.completed, _):
            VStack(alignment: .leading, spacing: 10) {
                Text("Break over")
                    .font(.headline)
                Button("Start focus") { engine.reset() }
                    .keyboardShortcut(.defaultAction)
            }
        }
    }

    // MARK: - Active focus

    private var activeFocus: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(engine.remainingClock)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(engine.state == .paused ? .secondary : .primary)

            if !engine.intent.isEmpty {
                Text("Focusing on")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(engine.intent)
                    .font(.headline)
            } else {
                Text(engine.state == .paused ? "Paused" : "Focusing…")
                    .font(.headline)
            }

            ThoughtCaptureView()

            HStack {
                if engine.state == .running {
                    Button("Pause") { engine.pause() }
                } else {
                    Button("Resume") { engine.resume() }
                        .keyboardShortcut(.defaultAction)
                }
                Button("Reset") { engine.reset() }
            }
        }
    }

    // MARK: - Active break / ritual

    private var activeBreak: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(engine.remainingClock)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)

            Text(engine.phase.title)
                .font(.headline)

            if !engine.restPrompt.isEmpty {
                Text(engine.restPrompt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                if engine.state == .running {
                    Button("Pause") { engine.pause() }
                } else {
                    Button("Resume") { engine.resume() }
                        .keyboardShortcut(.defaultAction)
                }
                Button("End break") { engine.reset() }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Label("\(store.todayCount) today", systemImage: "checkmark.circle")
            Spacer()
            Label("\(store.streak.currentStreak)d streak", systemImage: "flame")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    // MARK: - Settings

    private var settingsRow: some View {
        HStack {
            Toggle("Open at login", isOn: $launchAtLogin)
                .toggleStyle(.checkbox)
                .controlSize(.small)
                .onChange(of: launchAtLogin) { newValue in
                    LaunchAtLogin.set(newValue)
                }

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .font(.caption)
    }
}
