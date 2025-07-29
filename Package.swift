// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "FountainCoach",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "FountainCore", targets: ["FountainCore"]),
        .library(name: "FountainCodex", targets: ["FountainCodex"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.63.0")
    ],
    targets: [
        .target(name: "FountainCore", path: "Sources/FountainCore"),
        .target(
            name: "FountainCodex",
            dependencies: [
                "FountainCore",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                "Yams"
            ],
            path: "Sources/FountainCodex"
        ),
        .testTarget(name: "FountainCoreTests", dependencies: ["FountainCore"], path: "Tests/FountainCoreTests")
    ]
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
