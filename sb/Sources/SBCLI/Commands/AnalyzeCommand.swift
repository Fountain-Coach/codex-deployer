import Foundation
import SBCore

public struct AnalyzeCommand {
    public init() {}

    public func run(args: [String]) async throws {
        var snapshotPath: URL?
        var outDir: URL?
        var mode: DissectionMode = .standard
        var i = 0
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--snapshot":
                if i + 1 < args.count { snapshotPath = URL(fileURLWithPath: args[i + 1]); i += 1 }
            case "--out":
                if i + 1 < args.count { outDir = URL(fileURLWithPath: args[i + 1], isDirectory: true); i += 1 }
            case "--mode":
                if i + 1 < args.count, let m = DissectionMode(rawValue: args[i + 1]) { mode = m; i += 1 }
            default:
                break
            }
            i += 1
        }
        guard let snapshotPath else { throw CLIError.invalidArguments }

        let data = try Data(contentsOf: snapshotPath)
        let snapshot = try JSONDecoder().decode(Snapshot.self, from: data)
        let analysis = try await Dissector().analyze(from: snapshot, mode: mode, store: nil)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let dir = outDir {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try encoder.encode(analysis).write(to: dir.appendingPathComponent("analysis.json"))
        }
        let out = try encoder.encode(analysis)
        FileHandle.standardOutput.write(out)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
