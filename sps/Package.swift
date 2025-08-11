// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SPS",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "sps", targets: ["SPSCLI"]),
    ],
    targets: [
        .executableTarget(
            name: "SPSCLI",
            path: "Sources/SPSCLI",
            exclude: ["Resources"],
            resources: []
        ),
        .testTarget(
            name: "SPSCLITests",
            dependencies: ["SPSCLI"],
            path: "Tests/SPSCLITests"
        )
    ]
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
