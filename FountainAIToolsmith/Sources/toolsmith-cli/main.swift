import Toolsmith

@main
struct ToolsmithCLI {
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        let toolsmith = Toolsmith()
        _ = toolsmith.run(tool: "toolsmith-cli", metadata: ["args": args.joined(separator: " ")]) {
            print("Toolsmith CLI")
        }
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
