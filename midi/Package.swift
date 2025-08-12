// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MIDI2",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "MIDI2", targets: ["MIDI2"]),
        .executable(name: "IndexParser", targets: ["IndexParser"]),
    ],
    targets: [
        .target(
            name: "MIDI2",
            path: "Sources/MIDI2"
        ),
        .executableTarget(
            name: "IndexParser",
            path: "Sources/IndexParser"
        ),
        .testTarget(
            name: "MIDI2Tests",
            dependencies: ["MIDI2"],
            path: "Tests/MIDI2Tests"
        )
    ]
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
