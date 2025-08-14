// swift-tools-version: 6.1
import PackageDescription

var products: [Product] = [
    .library(name: "FountainCore", targets: ["FountainCore"]),
    .library(name: "FountainCodex", targets: ["FountainCodex"]),
    .library(name: "MIDI2Models", targets: ["MIDI2Models"]),
    .library(name: "MIDI2Core", targets: ["MIDI2Core"]),
    .library(name: "FlexBridge", targets: ["FlexBridge"]),
    .executable(name: "clientgen-service", targets: ["clientgen-service"]),
    .executable(name: "gateway-server", targets: ["gateway-server"]),
    .executable(name: "publishing-frontend", targets: ["publishing-frontend"])
]

var targets: [Target] = [
    .target(name: "FountainCore", path: "Sources/FountainCore"),
    .target(
        name: "FountainCodex",
        dependencies: [
            "FountainCore",
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOCore", package: "swift-nio"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
            "Yams",
            .product(name: "Crypto", package: "swift-crypto"),
            .product(name: "Logging", package: "swift-log")
        ],
        path: "Sources/FountainCodex"
    ),
    .executableTarget(
        name: "clientgen-service",
        dependencies: ["FountainCodex"],
        path: "Sources/clientgen-service"
    ),
    .executableTarget(
        name: "gateway-server",
        dependencies: [
            "FountainCodex",
            "PublishingFrontend",
            .product(name: "Crypto", package: "swift-crypto"),
            .product(name: "X509", package: "swift-certificates")
        ],
        path: "Sources/GatewayApp"
    ),
    .target(
        name: "PublishingFrontend",
        dependencies: ["FountainCodex", "Yams"],
        path: "Sources/PublishingFrontend"
    ),
    .executableTarget(
        name: "publishing-frontend",
        dependencies: ["PublishingFrontend"],
        path: "Sources/publishing-frontend"
    ),
    .target(name: "MIDI2Models", path: "Sources/MIDI2Models"),
    .target(name: "MIDI2Core", dependencies: [.product(name: "MIDI2", package: "midi2")], path: "Sources/MIDI2Core"),
    .target(name: "MIDI2Transports", path: "Sources/MIDI2Transports"),
    .target(
        name: "FlexBridge",
        dependencies: [
            "MIDI2Core",
            "MIDI2Transports"
        ],
        path: "Sources/FlexBridge"
    ),
    .testTarget(name: "FountainCoreTests", dependencies: ["FountainCore"], path: "Tests/FountainCoreTests"),
    .testTarget(name: "ClientGeneratorTests", dependencies: ["FountainCodex"], path: "Tests/ClientGeneratorTests"),
    .testTarget(name: "PublishingFrontendTests", dependencies: ["PublishingFrontend"], path: "Tests/PublishingFrontendTests"),
    .testTarget(name: "DNSTests", dependencies: ["PublishingFrontend", "FountainCodex", .product(name: "Crypto", package: "swift-crypto"), .product(name: "NIOEmbedded", package: "swift-nio"), .product(name: "NIO", package: "swift-nio")], path: "Tests/DNSTests"),
    .testTarget(name: "IntegrationRuntimeTests", dependencies: ["gateway-server", "FountainCodex"], path: "Tests/IntegrationRuntimeTests"),
    .testTarget(name: "DNSPerfTests", dependencies: ["FountainCodex", .product(name: "NIOCore", package: "swift-nio")], path: "Tests/DNSPerfTests"),
    .testTarget(name: "NormativeLinkerTests", dependencies: ["FountainCodex"], path: "Tests/NormativeLinkerTests"),
    .testTarget(name: "MIDI2ModelsTests", dependencies: ["MIDI2Models"], path: "Tests/MIDI2ModelsTests"),
    .testTarget(name: "MIDI2CoreTests", dependencies: ["MIDI2Core"], path: "Tests/MIDI2CoreTests"),
    .testTarget(name: "MIDI2TransportsTests", dependencies: ["MIDI2Transports"], path: "Tests/MIDI2TransportsTests")
]

#if os(Linux)
products.append(.library(name: "PDFiumExtractor", targets: ["PDFiumExtractor"]))
targets.append(.target(name: "PDFiumExtractor", dependencies: [], path: "Sources/PDFiumExtractor"))
#endif

let package = Package(
    name: "FountainCoach",
    platforms: [
        .macOS(.v14)
    ],
    products: products,
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.63.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/Fountain-Coach/midi2.git", from: "0.2.0")
    ],
    targets: targets
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
