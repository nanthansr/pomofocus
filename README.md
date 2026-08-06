# Pomofocus

**A macOS menu bar Pomodoro timer that never shows you a number.**

![Swift](https://img.shields.io/badge/Swift-6.x-F05138?logo=swift&logoColor=white)
![Platform](https://img.shields.io/badge/macOS-13%2B-000000?logo=apple&logoColor=white)
![No dependencies](https://img.shields.io/badge/dependencies-none-2ea44f)

## The problem

Every Pomodoro timer I tried put a countdown in my menu bar. `24:59`, `24:58`,
`24:57`. That number is a tiny anxiety generator sitting in your peripheral
vision, and glancing at it is itself a context switch — the exact thing the
technique is supposed to prevent.

So this one has no digits. The menu bar shows a ring that fills and warms from
green to red as a focus block ripens. You read it the way you read a fuel gauge:
a glance tells you roughly where you are, and nothing tells you precisely.

Everything else follows from taking that seriously.

## How it works

`PomodoroEngine` is the whole timing brain, and it stores an **end date, not a
remaining duration**. That single choice is what makes the app survive a closed
lid: a countdown decremented by a timer loses whatever time the machine spent
asleep, whereas a target timestamp is still correct on wake. The ring redraws
from `endDate - now` and is simply right.

The rest of the design is small and deliberate:

| Piece | What it does | Why it's built that way |
|---|---|---|
| `PomodoroEngine` | phase + timing | end-date anchored, so sleep and wake do not corrupt the session |
| `StreakTracker` | daily streak | carries a **weekly grace day**, so one missed day does not wipe a month of work |
| `ThoughtVault` | park a distraction | appends to a dated markdown file instead of a database, so the notes outlive the app |
| `SessionStore` | persistence | `UserDefaults` only — no schema, no migration, nothing to corrupt |
| `NotificationManager` | end-of-block alert | degrades safely when running outside an app bundle, where notifications are unavailable |

Intent capture comes before a block starts: one line answering "what am I
focusing on?", shown in the panel for the rest of the session. After a focus
block ends, a rest ritual offers something specific — look away, stretch, drink
water — rather than a generic five minutes.

## By the numbers

- **15 Swift files**, no third-party dependencies at all
- **5 unit tests** covering `StreakTracker`, including the grace-day boundary
- **Zero** network calls, analytics, or accounts — nothing leaves the machine
- Thought captures land in `~/Library/Application Support/Pomofocus/thoughts/YYYY-MM-DD.md`

## Run it

```bash
git clone https://github.com/nanthansr/pomofocus
cd pomofocus
./Scripts/build_app.sh && open build/Pomofocus.app
```

That produces a proper menu bar app — no Dock icon, notifications enabled —
using only the Swift command line tools. **Xcode is not required.**

For development, `swift build && swift run Pomofocus` is faster, but a bare
executable can appear in the Dock and cannot post notifications. Use the build
script for the real behaviour.

Tests need XCTest, which ships with full Xcode:

```bash
swift test
```

## What I'd do next

- **The tests are thin.** `StreakTracker` is covered; `PomodoroEngine` is not, and it is the component where a bug would be most expensive. Testing it properly means injecting a clock rather than reading `Date()` directly.
- **No sound design.** The end-of-block notification is the system default. A quiet chime would fit an app whose whole thesis is "do not startle the user".
- **The ring is not accessible.** Colour is currently the only channel carrying progress, which fails for red-green colour blindness. It needs a second channel — fill angle is already there, so exposing a VoiceOver label is the cheaper half of the fix.

## Layout

```
Pomofocus/
  PomofocusApp.swift          app entry + MenuBarExtra wiring
  Models/
    SessionPhase.swift        phase and state enums
    PomodoroEngine.swift      timing brain, end-date anchored
    StreakTracker.swift       streak with a weekly grace budget
  Services/
    SessionStore.swift        UserDefaults persistence
    NotificationManager.swift system notifications
    ThoughtVault.swift        markdown thought capture
    LaunchAtLogin.swift       login item toggle
  Views/
    ProgressRingView.swift    the ripening ring
    MenuBarRingView.swift     menu bar rendering
    MenuContentView.swift     dropdown panel
    IntentInputView.swift     pre-session intent
    ThoughtCaptureView.swift  inline capture
    RestRitualView.swift      post-focus rest prompts
```

## Defaults

Focus 25 minutes · short break 5 · rest ritual 5.

---

Built by [Nanthan SR](https://nanthansr.github.io/). MIT.
