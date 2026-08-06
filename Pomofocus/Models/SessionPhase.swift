import Foundation

/// Which kind of block the engine is currently running.
enum SessionPhase {
    case work
    case shortBreak
    case restRitual

    var title: String {
        switch self {
        case .work: return "Focus"
        case .shortBreak: return "Break"
        case .restRitual: return "Rest ritual"
        }
    }
}

/// Where a phase is in its lifecycle.
enum SessionState {
    case idle
    case running
    case paused
    case completed
}
