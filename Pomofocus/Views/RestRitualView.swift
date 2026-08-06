import SwiftUI

/// Shown after a focus block completes. Offers three intentional rest prompts;
/// picking one starts a timed 5-minute rest ritual.
struct RestRitualView: View {
    @ObservedObject var engine: PomodoroEngine

    private let prompts = [
        "Look away from the screen",
        "Stand up and stretch",
        "Drink some water"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rest with intention")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(prompts, id: \.self) { prompt in
                Button {
                    engine.startRestRitual(prompt: prompt)
                } label: {
                    HStack {
                        Text(prompt)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.bordered)
            }

            Button("Quick break instead") {
                engine.startShortBreak()
            }
            .font(.caption)
        }
    }
}
