import Foundation
import ToolsmithAPI
import ToolsmithSupport

@main
struct ToolsmithCLI {
    static func main() async throws {
        let args = Array(CommandLine.arguments.dropFirst())
        guard let command = args.first else {
            printUsage()
            return
        }
        let baseURL = URL(string: ProcessInfo.processInfo.environment["TOOLSERVER_URL"] ?? "http://localhost:8080")!
        let client = APIClient(baseURL: baseURL)
        switch command {
        case "health-check":
            let data = try await client.send(health_check())
            if let text = String(data: data, encoding: .utf8) { print(text) }
        case "manifest":
            let data = try await client.send(manifest())
            let manifest = try JSONDecoder().decode(ToolManifest.self, from: data)
            print(manifest)
        case "convert-image":
            guard args.count >= 3 else { print("Usage: toolsmith-cli convert-image <input> <output>"); return }
            let input = args[1]; let output = args[2]
            let ext = URL(fileURLWithPath: output).pathExtension
            let req = convert_image(args: [input, "\(ext):-"])
            let out = try await client.send(req)
            try Data(out).write(to: URL(fileURLWithPath: output))
            print("wrote \(output)")
        case "transcode-audio":
            guard args.count >= 3 else { print("Usage: toolsmith-cli transcode-audio <input> <output>"); return }
            let input = args[1]; let output = args[2]
            let ext = URL(fileURLWithPath: output).pathExtension
            let req = transcode_audio(args: ["-i", input, "-f", ext, "pipe:1"])
            let out = try await client.send(req)
            try Data(out).write(to: URL(fileURLWithPath: output))
            print("wrote \(output)")
        case "convert-plist":
            guard args.count >= 3 else { print("Usage: toolsmith-cli convert-plist <input> <output>"); return }
            let input = args[1]; let output = args[2]
            let format = URL(fileURLWithPath: output).pathExtension == "xml" ? "xml1" : "binary1"
            let req = convert_plist(args: ["-convert", format, "-o", "-", input])
            let out = try await client.send(req)
            try Data(out).write(to: URL(fileURLWithPath: output))
            print("wrote \(output)")
        default:
            printUsage()
        }
    }

    static func printUsage() {
        print("""
Usage: toolsmith-cli <command> [args]
Commands:
  health-check
  manifest
  convert-image <input> <output>
  transcode-audio <input> <output>
  convert-plist <input> <output>
""")
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
