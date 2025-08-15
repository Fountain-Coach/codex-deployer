import Foundation
import SBCore

public struct IndexCommand {
    public init() {}

    public func run(args: [String]) async throws {
        var analysisPath: URL?
        var tsURL: URL?
        var apiKey: String?
        var i = 0
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--analysis":
                if i + 1 < args.count { analysisPath = URL(fileURLWithPath: args[i + 1]); i += 1 }
            case "--typesense-url":
                if i + 1 < args.count { tsURL = URL(string: args[i + 1]); i += 1 }
            case "--typesense-key":
                if i + 1 < args.count { apiKey = args[i + 1]; i += 1 }
            default:
                break
            }
            i += 1
        }
        guard let analysisPath, let tsURL, let apiKey else { throw CLIError.invalidArguments }

        let data = try Data(contentsOf: analysisPath)
        let analysis = try JSONDecoder().decode(Analysis.self, from: data)
        var options = IndexOptions(enabled: true)
        options.typesense = .init(url: tsURL, apiKey: apiKey, timeoutMs: nil)
        let result = try await TypesenseIndexer().upsert(analysis: analysis, options: options)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let out = try encoder.encode(result)
        FileHandle.standardOutput.write(out)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
