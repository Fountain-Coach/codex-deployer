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
    dependencies: [],
    targets: [
        .target(name: "Toolsmith", dependencies: []),
        .target(name: "SandboxRunner", dependencies: []),
        .target(name: "ToolsmithAPI", dependencies: []),
        .executableTarget(name: "toolsmith-cli", dependencies: ["Toolsmith"])
    ]
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
