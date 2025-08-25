import Foundation
import SBCore

@main
struct SBCLI {
    static func main() async throws {
        var args = CommandLine.arguments.dropFirst()
        guard let command = args.first else {
            print("usage: sb <browse|analyze|index> ...")
            return
        }
        args = args.dropFirst()
        switch command {
        case "browse":
            try await BrowseCommand().run(args: Array(args))
        case "analyze":
            try await AnalyzeCommand().run(args: Array(args))
        case "index":
            try await IndexCommand().run(args: Array(args))
        default:
            print("unknown command \(command)")
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
