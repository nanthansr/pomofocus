import XCTest
@testable import Pomofocus

final class StreakTrackerTests: XCTestCase {
    private func makeTracker() -> StreakTracker {
        let defaults = UserDefaults(suiteName: "streak.tests.\(UUID().uuidString)")!
        return StreakTracker(defaults: defaults)
    }

    private func day(_ offset: Int, from base: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: base)!
    }

    func testFirstFocusDayStartsStreakAtOne() {
        let tracker = makeTracker()
        tracker.registerFocusDay(now: day(0))
        XCTAssertEqual(tracker.currentStreak, 1)
    }

    func testSameDayIsIdempotent() {
        let tracker = makeTracker()
        tracker.registerFocusDay(now: day(0))
        tracker.registerFocusDay(now: day(0))
        XCTAssertEqual(tracker.currentStreak, 1)
    }

    func testConsecutiveDaysIncrementStreak() {
        let tracker = makeTracker()
        tracker.registerFocusDay(now: day(0))
        tracker.registerFocusDay(now: day(1))
        tracker.registerFocusDay(now: day(2))
        XCTAssertEqual(tracker.currentStreak, 3)
    }

    func testSingleMissUsesGraceAndKeepsStreak() {
        let tracker = makeTracker()
        tracker.registerFocusDay(now: day(0))
        // skip day 1, come back day 2 — grace should absorb the miss
        tracker.registerFocusDay(now: day(2))
        XCTAssertEqual(tracker.currentStreak, 2)
    }

    func testLongGapResetsStreak() {
        let tracker = makeTracker()
        tracker.registerFocusDay(now: day(0))
        tracker.registerFocusDay(now: day(5))
        XCTAssertEqual(tracker.currentStreak, 1)
    }
}
