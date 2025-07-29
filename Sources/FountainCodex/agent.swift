import Foundation

/// Codex orchestration entry point describing how to build and test the project.
struct Agent {
    static func main() throws {
        print("""
        Codex Orchestration Steps:
        1. Run the generator:\n   swift run generator --input OpenAPI/api.yaml --output Generated/
        2. Run tests:\n   swift test -v
        3. Commit any changes under Generated/ and Sources/.
        """)
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
