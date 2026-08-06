import SwiftUI

/// The pre-session prompt: shows the selected focus length, lets you change it,
/// captures an optional intent, and starts the block.
struct IntentInputView: View {
    @ObservedObject var engine: PomodoroEngine
    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(engine.durationClock)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .frame(maxWidth: .infinity, alignment: .center)

            Picker("Focus length", selection: $engine.workMinutes) {
                ForEach(PomodoroEngine.durationPresets, id: \.self) { minutes in
                    Text("\(minutes)m").tag(minutes)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            Text("What are you focusing on?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("e.g. Write client proposal", text: $engine.intent)
                .textFieldStyle(.roundedBorder)
                .focused($fieldFocused)
                .onSubmit { engine.startWork() }

            Button {
                engine.startWork()
            } label: {
                Text("Start focus")
                    .frame(maxWidth: .infinity)
            }
            .keyboardShortcut(.defaultAction)
        }
    }
}
