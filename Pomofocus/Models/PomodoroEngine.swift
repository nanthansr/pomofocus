import AppKit
import Combine
import Foundation

/// The timing brain of the app. Drives one phase at a time (work / break /
/// rest ritual) and publishes just enough state for the UI to draw the ring
/// and controls.
///
/// Timing is anchored to an `endDate` rather than a running counter, so if the
/// Mac sleeps mid-session the remaining time is still correct on wake.
final class PomodoroEngine: ObservableObject {
    static let workMinutesKey = "settings.workMinutes"

    /// Preset focus lengths offered in the panel.
    static let durationPresets = [15, 25, 45, 50]

    let shortBreakDuration: TimeInterval = 5 * 60
    let restRitualDuration: TimeInterval = 5 * 60

    /// User-configurable focus length in minutes. Persisted, and while idle it
    /// updates the displayed remaining time immediately.
    @Published var workMinutes: Int {
        didSet {
            UserDefaults.standard.set(workMinutes, forKey: Self.workMinutesKey)
            if state == .idle {
                remaining = workDuration
            }
        }
    }

    @Published private(set) var phase: SessionPhase = .work
    @Published private(set) var state: SessionState = .idle
    @Published private(set) var remaining: TimeInterval = 25 * 60
    @Published private(set) var restPrompt: String = ""
    @Published var intent: String = ""

    private var endDate: Date?
    private var ticker: Timer?
    private let store: SessionStore

    init(store: SessionStore) {
        self.store = store
        let saved = UserDefaults.standard.integer(forKey: Self.workMinutesKey)
        self.workMinutes = saved > 0 ? saved : 25
        self.remaining = TimeInterval((saved > 0 ? saved : 25) * 60)
        NotificationManager.requestAuthorization()
        observeWake()
    }

    // MARK: - Derived values

    var workDuration: TimeInterval {
        TimeInterval(workMinutes * 60)
    }

    var phaseDuration: TimeInterval {
        switch phase {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .restRitual: return restRitualDuration
        }
    }

    /// 0.0 (just started) to 1.0 (complete). The ring fills as this grows.
    var progress: Double {
        guard phaseDuration > 0 else { return 0 }
        let elapsed = phaseDuration - remaining
        return min(max(elapsed / phaseDuration, 0), 1)
    }

    /// "MM:SS" of time left in the current phase, for display in the panel.
    var remainingClock: String {
        Self.clockString(from: remaining)
    }

    /// "MM:SS" of the currently selected focus length, shown while idle.
    var durationClock: String {
        Self.clockString(from: workDuration)
    }

    static func clockString(from interval: TimeInterval) -> String {
        let seconds = max(Int(interval.rounded()), 0)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Starting phases

    func startWork() {
        phase = .work
        restPrompt = ""
        beginPhase(duration: workDuration)
    }

    func startShortBreak() {
        phase = .shortBreak
        restPrompt = ""
        beginPhase(duration: shortBreakDuration)
    }

    func startRestRitual(prompt: String) {
        phase = .restRitual
        restPrompt = prompt
        beginPhase(duration: restRitualDuration)
    }

    private func beginPhase(duration: TimeInterval) {
        remaining = duration
        endDate = Date().addingTimeInterval(duration)
        state = .running
        startTicking()
    }

    // MARK: - Controls

    func pause() {
        guard state == .running else { return }
        if let endDate {
            remaining = max(endDate.timeIntervalSinceNow, 0)
        }
        state = .paused
        stopTicking()
    }

    func resume() {
        guard state == .paused else { return }
        endDate = Date().addingTimeInterval(remaining)
        state = .running
        startTicking()
    }

    func reset() {
        stopTicking()
        endDate = nil
        phase = .work
        remaining = workDuration
        state = .idle
        restPrompt = ""
        intent = ""
    }

    // MARK: - Ticking

    private func startTicking() {
        stopTicking()
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func stopTicking() {
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard state == .running, let endDate else { return }
        remaining = max(endDate.timeIntervalSinceNow, 0)
        if remaining <= 0 {
            completePhase()
        }
    }

    private func completePhase() {
        stopTicking()
        remaining = 0
        let finished = phase
        state = .completed

        switch finished {
        case .work:
            store.recordCompletedWorkSession(intent: intent)
            NotificationManager.notify(
                title: "Focus complete",
                body: "Nice work. Time for a break."
            )
        case .shortBreak, .restRitual:
            NotificationManager.notify(
                title: "Break over",
                body: "Ready for the next focus block?"
            )
        }
    }

    // MARK: - Sleep / wake

    private func observeWake() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    @objc private func handleWake() {
        tick()
    }
}
