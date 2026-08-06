import SwiftUI

/// The menu bar indicator. Shows a filling ring that "ripens" from cool green
/// to warm red as a focus session progresses. Break and rest phases use a calm
/// blue-green instead. No numbers ever appear here — progress is purely visual.
struct ProgressRingView: View {
    let progress: Double
    let phase: SessionPhase
    let state: SessionState

    private let size: CGFloat = 14
    private let lineWidth: CGFloat = 2

    // Tomato red — used for the idle state so the icon reads as a small tomato
    // and stands out from the monochrome menu bar icons around it.
    private let tomato = Color(red: 0.90, green: 0.28, blue: 0.24)

    var body: some View {
        ZStack {
            // Always-visible solid track so the icon is easy to spot even at 0%.
            Circle()
                .stroke(state == .idle ? tomato : Color.primary, lineWidth: lineWidth)

            // A filled tomato-red center dot when idle makes the icon read as a
            // clear, recognizable target rather than an empty circle.
            if state == .idle {
                Circle()
                    .fill(tomato)
                    .frame(width: 5, height: 5)
            }

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .opacity(state == .paused ? 0.4 : 1)
        }
        .frame(width: size, height: size)
        .padding(.horizontal, 2)
        .animation(.easeInOut(duration: 0.3), value: progress)
        .accessibilityLabel("\(phase.title) progress")
        .accessibilityValue("\(Int(progress * 100)) percent complete")
    }

    private var ringColor: Color {
        switch phase {
        case .work:
            return ripenColor(for: progress)
        case .shortBreak, .restRitual:
            return Color(red: 0.30, green: 0.70, blue: 0.65)
        }
    }

    /// Interpolate green -> amber -> red as the focus block ripens.
    private func ripenColor(for t: Double) -> Color {
        let cool = (r: 0.30, g: 0.72, b: 0.42)
        let mid = (r: 0.95, g: 0.72, b: 0.25)
        let hot = (r: 0.90, g: 0.28, b: 0.24)

        if t < 0.5 {
            return blend(cool, mid, t / 0.5)
        } else {
            return blend(mid, hot, (t - 0.5) / 0.5)
        }
    }

    private func blend(
        _ a: (r: Double, g: Double, b: Double),
        _ b: (r: Double, g: Double, b: Double),
        _ t: Double
    ) -> Color {
        let clamped = min(max(t, 0), 1)
        return Color(
            red: a.r + (b.r - a.r) * clamped,
            green: a.g + (b.g - a.g) * clamped,
            blue: a.b + (b.b - a.b) * clamped
        )
    }
}
