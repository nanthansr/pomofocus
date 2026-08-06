import Combine
import Foundation

/// Owns the small amount of state we persist between launches: how many focus
/// sessions finished today, and the streak. Everything lives in `UserDefaults`
/// — no accounts, no cloud, no database.
final class SessionStore: ObservableObject {
    @Published private(set) var todayCount: Int = 0

    let streak: StreakTracker

    private let defaults: UserDefaults
    private let calendar = Calendar.current

    private enum Key {
        static let todayCount = "sessions.todayCount"
        static let todayDate = "sessions.todayDate"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.streak = StreakTracker(defaults: defaults)
        loadTodayCount()
    }

    /// Record a finished 25-minute work block.
    func recordCompletedWorkSession(intent: String) {
        rolloverIfNeeded()
        todayCount += 1
        defaults.set(todayCount, forKey: Key.todayCount)
        streak.registerFocusDay()
    }

    private func loadTodayCount() {
        rolloverIfNeeded()
        todayCount = defaults.integer(forKey: Key.todayCount)
    }

    /// Reset the daily counter when the calendar day changes.
    private func rolloverIfNeeded() {
        let today = calendar.startOfDay(for: Date())
        let stored = defaults.object(forKey: Key.todayDate) as? Date

        if stored == nil || !calendar.isDate(stored!, inSameDayAs: today) {
            defaults.set(today, forKey: Key.todayDate)
            defaults.set(0, forKey: Key.todayCount)
            todayCount = 0
        }
    }
}
