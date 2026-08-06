import Foundation

/// Appends quick thoughts to a per-day markdown file so a distracting idea can
/// be parked without leaving the current focus block.
///
/// Files live at:
///   ~/Library/Application Support/Pomofocus/thoughts/YYYY-MM-DD.md
enum ThoughtVault {
    static func capture(_ raw: String, now: Date = Date()) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        guard let fileURL = try? fileURL(for: now) else { return }

        let time = timeFormatter.string(from: now)
        let line = "- \(time) — \(text)\n"

        append(line, to: fileURL)
    }

    // MARK: - Paths

    private static func thoughtsDirectory() throws -> URL {
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dir = base
            .appendingPathComponent("Pomofocus", isDirectory: true)
            .appendingPathComponent("thoughts", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func fileURL(for date: Date) throws -> URL {
        let name = dayFormatter.string(from: date) + ".md"
        return try thoughtsDirectory().appendingPathComponent(name)
    }

    // MARK: - Writing

    private static func append(_ line: String, to url: URL) {
        guard let data = line.data(using: .utf8) else { return }

        if FileManager.default.fileExists(atPath: url.path),
           let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        } else {
            let header = "# Thoughts — \(dayFormatter.string(from: Date()))\n\n"
            try? (header + line).data(using: .utf8)?.write(to: url)
        }
    }

    // MARK: - Formatters

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}
