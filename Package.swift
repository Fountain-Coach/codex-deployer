// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "FountainCoach",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "FountainCore", targets: ["FountainCore"]),
        .library(name: "FountainCodex", targets: ["FountainCodex"]),
        .executable(name: "clientgen-service", targets: ["clientgen-service"]),
        .executable(name: "gateway-server", targets: ["gateway-server"]),
        .executable(name: "publishing-frontend", targets: ["publishing-frontend"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.63.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/m-barthelemy/AcmeSwift.git", branch: "main")
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
                "Yams",
                .product(name: "Crypto", package: "swift-crypto")
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
            dependencies: ["FountainCodex", "PublishingFrontend", .product(name: "AcmeSwift", package: "AcmeSwift")],
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
        .testTarget(name: "FountainCoreTests", dependencies: ["FountainCore"], path: "Tests/FountainCoreTests"),
        .testTarget(name: "ClientGeneratorTests", dependencies: ["FountainCodex"], path: "Tests/ClientGeneratorTests"),
        .testTarget(name: "PublishingFrontendTests", dependencies: ["PublishingFrontend"], path: "Tests/PublishingFrontendTests"),
        .testTarget(name: "DNSTests", dependencies: ["PublishingFrontend", "FountainCodex", .product(name: "Crypto", package: "swift-crypto")], path: "Tests/DNSTests"),
        .testTarget(name: "IntegrationRuntimeTests", dependencies: ["gateway-server", "FountainCodex", "PublishingFrontend"], path: "Tests/IntegrationRuntimeTests")
    ]
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
