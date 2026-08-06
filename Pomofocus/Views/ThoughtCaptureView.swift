import SwiftUI

/// A small inline capture box shown during a focus session. Type a stray
/// thought, hit save, and it is appended to today's markdown file so you can
/// let it go and keep focusing.
struct ThoughtCaptureView: View {
    @State private var text: String = ""
    @State private var justSaved = false
    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                TextField("Park a thought…", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .focused($fieldFocused)
                    .onSubmit(save)

                Button("Save", action: save)
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if justSaved {
                Text("Saved to today's thoughts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
    }

    private func save() {
        let entry = text
        guard !entry.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        ThoughtVault.capture(entry)
        text = ""
        withAnimation { justSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { justSaved = false }
        }
    }
}
