# AGENTS.md

## Learned User Preferences

- Wants to learn Swift/SwiftUI/AppKit: build features and teach side-by-side with short "Learning note" explanations in chat.
- Prefers native macOS patterns over web stacks (no Electron/Tauri).
- Prefers local-first: no accounts, cloud sync, or subscriptions.
- Works via a plan-then-implement flow (brainstorm, create plan, then implement the plan's todos).

## Learned Workspace Facts

- Pomofocus is a native macOS menu bar Pomodoro app (Swift + SwiftUI + AppKit) built with Swift Package Manager (`Package.swift`).
- Full Xcode is NOT installed; only Swift command line tools. Build/run with `swift build` and `swift run`.
- Deployment target is macOS 13: use `ObservableObject`/`@Published` (not `@Observable`), and the single-parameter `onChange` (two-parameter form needs macOS 14).
- Build a real menu bar `.app` bundle without Xcode via `./Scripts/build_app.sh` (produces `build/Pomofocus.app`, ad-hoc codesigned, `LSUIElement` set).
- `UNUserNotificationCenter` notifications and `SMAppService` launch-at-login only work from a bundled `.app`, not `swift run`; guard for bundle presence.
- XCTest tests in `Tests/PomofocusTests/` need full Xcode; the test target is excluded from `Package.swift` so `swift build` works under Command Line Tools.
- XcodeGen is available; `xcodegen generate` creates `Pomofocus.xcodeproj`.
- Source layout: `Pomofocus/{PomofocusApp.swift, Models/, Services/, Views/}`; app icon at `Pomofocus/AppIcon.icns`.
- Menu bar icon must be visual-only (filling ring, no countdown numbers); panel text/stats are fine.
- No PIL/Python imaging available; generate icons with `sips` + `Scripts/round_icon.swift` (CoreGraphics) + `iconutil`.
