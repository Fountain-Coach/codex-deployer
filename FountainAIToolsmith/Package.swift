// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "FountainAIToolsmith",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "Toolsmith", targets: ["Toolsmith"]),
        .library(name: "SandboxRunner", targets: ["SandboxRunner"]),
        .library(name: "ToolsmithAPI", targets: ["ToolsmithAPI"]),
        .executable(name: "toolsmith-cli", targets: ["toolsmith-cli"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "ToolsmithSupport", dependencies: [.product(name: "Crypto", package: "swift-crypto")]),
        .target(name: "Toolsmith", dependencies: ["ToolsmithSupport"]),
        .target(name: "SandboxRunner", dependencies: ["ToolsmithSupport"], resources: [.process("Profiles")]),
        .target(name: "ToolsmithAPI", dependencies: []),
        .executableTarget(name: "toolsmith-cli", dependencies: ["ToolsmithAPI", "ToolsmithSupport"]),
        .testTarget(name: "SandboxRunnerTests", dependencies: ["SandboxRunner", "Toolsmith", "ToolsmithSupport"]),
        .testTarget(name: "ToolsmithAPITests", dependencies: ["ToolsmithAPI"])
    ]
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
