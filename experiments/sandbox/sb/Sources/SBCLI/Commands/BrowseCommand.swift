import Foundation
import SBCore

public struct BrowseCommand {
    public init() {}

    public func run(args: [String]) async throws {
        var url: URL?
        var outDir: URL?
        var mode: DissectionMode = .quick
        var i = 0
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--url":
                if i + 1 < args.count { url = URL(string: args[i + 1]); i += 1 }
            case "--out":
                if i + 1 < args.count { outDir = URL(fileURLWithPath: args[i + 1], isDirectory: true); i += 1 }
            case "--mode":
                if i + 1 < args.count, let m = DissectionMode(rawValue: args[i + 1]) { mode = m; i += 1 }
            default:
                break
            }
            i += 1
        }
        guard let targetURL = url else { throw CLIError.invalidArguments }

        let navigator = URLNavigator()
        let dissector = Dissector()
        let indexer = TypesenseIndexer()
        let sb = SB(navigator: navigator, dissector: dissector, indexer: indexer, store: nil)
        let wait = WaitPolicy(strategy: .domContentLoaded, maxWaitMs: 15000)
        let (snap, analysis, _) = try await sb.browseAndDissect(url: targetURL, wait: wait, mode: mode, index: nil)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let dir = outDir {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try encoder.encode(snap).write(to: dir.appendingPathComponent("snapshot.json"))
            if let analysis = analysis {
                try encoder.encode(analysis).write(to: dir.appendingPathComponent("analysis.json"))
            }
        }
        let out = try encoder.encode(snap)
        FileHandle.standardOutput.write(out)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
