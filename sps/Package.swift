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
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "SPSCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
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
