import Foundation

/// Tracks a daily focus streak with a forgiving weekly grace budget.
///
/// A "focus day" is any calendar day where at least one work session finished.
/// Missing a day normally resets the streak, but each week you get one grace
/// day that absorbs a single miss so real life does not nuke your progress.
final class StreakTracker: ObservableObject {
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var graceRemaining: Int = 1

    private let defaults: UserDefaults
    private let calendar = Calendar.current

    private enum Key {
        static let streak = "streak.current"
        static let lastFocus = "streak.lastFocusDate"
        static let graceWeek = "streak.graceWeekKey"
        static let graceRemaining = "streak.graceRemaining"
    }

    private let graceBudgetPerWeek = 1

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        currentStreak = defaults.integer(forKey: Key.streak)
        if defaults.object(forKey: Key.graceRemaining) == nil {
            graceRemaining = graceBudgetPerWeek
        } else {
            graceRemaining = defaults.integer(forKey: Key.graceRemaining)
        }
    }

    private var lastFocusDate: Date? {
        defaults.object(forKey: Key.lastFocus) as? Date
    }

    /// Call when a work session completes. Idempotent within a single day.
    func registerFocusDay(now: Date = Date()) {
        let today = calendar.startOfDay(for: now)

        if let last = lastFocusDate, calendar.isDate(last, inSameDayAs: today) {
            return
        }

        refreshGraceIfNewWeek(today)

        if let last = lastFocusDate {
            let gap = calendar.dateComponents([.day], from: last, to: today).day ?? 0
            let missedDays = max(gap - 1, 0)

            if missedDays == 0 {
                currentStreak += 1
            } else if missedDays <= graceRemaining {
                graceRemaining -= missedDays
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        defaults.set(today, forKey: Key.lastFocus)
        defaults.set(currentStreak, forKey: Key.streak)
        defaults.set(graceRemaining, forKey: Key.graceRemaining)
    }

    private func refreshGraceIfNewWeek(_ day: Date) {
        let key = weekKey(for: day)
        let stored = defaults.string(forKey: Key.graceWeek)
        if stored != key {
            defaults.set(key, forKey: Key.graceWeek)
            graceRemaining = graceBudgetPerWeek
            defaults.set(graceRemaining, forKey: Key.graceRemaining)
        }
    }

    private func weekKey(for day: Date) -> String {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: day)
        return "\(comps.yearForWeekOfYear ?? 0)-W\(comps.weekOfYear ?? 0)"
    }
}
