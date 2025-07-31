// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "FountainAiLauncher",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "FountainAiLauncher", targets: ["FountainAiLauncher"])
    ],
    targets: [
        .executableTarget(
            name: "FountainAiLauncher",
            path: "Sources/FountainAiLauncher"
        ),
        .testTarget(
            name: "FountainAiLauncherTests",
            dependencies: ["FountainAiLauncher"],
            path: "Tests/FountainAiLauncherTests"
        )
    ]
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
