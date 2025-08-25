// swift-tools-version: 6.1
import PackageDescription
 
var products: [Product] = [
    .library(name: "FountainCodex", targets: ["FountainCodex"]),
    .library(name: "MIDI2Models", targets: ["MIDI2Models"]),
    .library(name: "MIDI2Core", targets: ["MIDI2Core"]),
    .library(name: "FlexBridge", targets: ["FlexBridge"]),
    .library(name: "SSEOverMIDI", targets: ["SSEOverMIDI"]),
    .executable(name: "clientgen-service", targets: ["clientgen-service"]),
    .executable(name: "gateway-server", targets: ["gateway-server"]),
    .executable(name: "publishing-frontend", targets: ["publishing-frontend"]),
    .executable(name: "flexctl", targets: ["flexctl"]),
    .executable(name: "tools-factory-server", targets: ["tools-factory-server"])
]

var targets: [Target] = [
    .target(
        name: "FountainCodex",
        dependencies: [
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOCore", package: "swift-nio"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
            "Yams",
            .product(name: "Crypto", package: "swift-crypto"),
            .product(name: "Logging", package: "swift-log")
        ],
        path: "libs/FountainCodex",
        exclude: ["FountainCodex/DNS/README.md"]
    ),
    .executableTarget(
        name: "clientgen-service",
        dependencies: ["FountainCodex"],
        path: "apps/ClientgenService"
    ),
    .executableTarget(
        name: "gateway-server",
        dependencies: [
            "FountainCodex",
            "PublishingFrontend",
            "LLMGatewayPlugin",
            "LLMGatewayClient",
            .product(name: "Crypto", package: "swift-crypto"),
            .product(name: "X509", package: "swift-certificates"),
            "Yams"
        ],
        path: "apps/GatewayServer"
    ),
    .target(
        name: "LLMGatewayClient",
        path: "Sources/FountainOps/Generated/Client/llm-gateway",
        sources: ["APIClient.swift", "APIRequest.swift"]
    ),
    .target(
        name: "LLMGatewayPlugin",
        dependencies: ["FountainCodex"],
        path: "libs/GatewayPlugins/LLMGatewayPlugin"
    ),
    .target(
        name: "ServiceShared",
        path: "Sources/FountainOps/Generated/Server/Shared"
    ),
    .target(
        name: "LLMGatewayService",
        dependencies: ["ServiceShared"],
        path: "Sources/FountainOps/Generated/Server/llm-gateway"
    ),
    .target(
        name: "PublishingFrontend",
        dependencies: ["FountainCodex", "Yams"],
        path: "libs/PublishingFrontend"
    ),
    .executableTarget(
        name: "publishing-frontend",
        dependencies: ["PublishingFrontend"],
        path: "apps/PublishingFrontendCLI"
    ),
    .target(name: "ResourceLoader", path: "libs/ResourceLoader"),
    .target(
        name: "MIDI2Models",
        dependencies: ["ResourceLoader"],
        path: "libs/MIDI2/MIDI2Models",
        resources: [.process("MIDI2Models/Resources")]
    ),
    .target(name: "MIDI2Core", dependencies: [.product(name: "MIDI2", package: "midi2")], path: "libs/MIDI2/MIDI2Core"),
    .target(name: "MIDI2Transports", path: "libs/MIDI2/MIDI2Transports"),
    .target(name: "SSEOverMIDI", dependencies: ["MIDI2Core", "MIDI2Transports", .product(name: "MIDI2", package: "midi2")], path: "libs/MIDI2/SSEOverMIDI"),
    .target(
        name: "FlexBridge",
        dependencies: [
            "MIDI2Core",
            "MIDI2Transports"
        ],
        path: "libs/MIDI2/FlexBridge"
    ),
    .executableTarget(
        name: "flexctl",
        dependencies: ["MIDI2Core", .product(name: "MIDI2", package: "midi2")],
        path: "apps/Flexctl",
        resources: [.process("flexctl/Resources")]
    ),
    .target(
        name: "ToolServer",
        dependencies: [.product(name: "Crypto", package: "swift-crypto")],
        path: "libs/ToolServer",
        exclude: ["Service", "Dockerfile"],
        resources: [.process("openapi.yaml")]
    ),
    .executableTarget(
        name: "tools-factory-server",
        dependencies: ["ToolServer"],
        path: "apps/ToolsFactoryServer"
    ),
    .testTarget(name: "ClientGeneratorTests", dependencies: ["FountainCodex"], path: "Tests/ClientGeneratorTests"),
    .testTarget(name: "PublishingFrontendTests", dependencies: ["PublishingFrontend"], path: "Tests/PublishingFrontendTests"),
    .testTarget(name: "DNSTests", dependencies: ["PublishingFrontend", "FountainCodex", .product(name: "Crypto", package: "swift-crypto"), .product(name: "NIOEmbedded", package: "swift-nio"), .product(name: "NIO", package: "swift-nio")], path: "Tests/DNSTests"),
    .testTarget(
        name: "IntegrationRuntimeTests",
        dependencies: ["gateway-server", "FountainCodex", "LLMGatewayService"],
        path: "Tests/IntegrationRuntimeTests",
        resources: [.process("Fixtures")]
    ),
    .testTarget(name: "DNSPerfTests", dependencies: ["FountainCodex", .product(name: "NIOCore", package: "swift-nio")], path: "Tests/DNSPerfTests"),
    .testTarget(name: "MIDI2ModelsTests", dependencies: ["MIDI2Models"], path: "Tests/MIDI2ModelsTests"),
    .testTarget(name: "MIDI2CoreTests", dependencies: ["MIDI2Core", "ResourceLoader", "flexctl"], path: "Tests/MIDI2CoreTests"),
    .testTarget(name: "MIDI2TransportsTests", dependencies: ["MIDI2Transports"], path: "Tests/MIDI2TransportsTests"),
    .testTarget(name: "FlexctlTests", dependencies: ["flexctl", "ResourceLoader"], path: "Tests/FlexctlTests"),
    .testTarget(name: "GatewayAppTests", dependencies: ["gateway-server", "LLMGatewayClient", "LLMGatewayPlugin"], path: "Tests/GatewayAppTests"),
    .testTarget(name: "FountainOpsTests", dependencies: ["LLMGatewayService"], path: "Tests/FountainOpsTests"),
    .testTarget(name: "ToolServerTests", dependencies: ["ToolServer"], path: "Tests/ToolServerTests"),
    .testTarget(
        name: "ToolsmithPackageTests",
        dependencies: [
            .product(name: "Toolsmith", package: "toolsmith"),
            .product(name: "SandboxRunner", package: "toolsmith"),
            .product(name: "ToolsmithSupport", package: "toolsmith"),
            .product(name: "ToolsmithAPI", package: "toolsmith")
        ],
        path: "Tests/ToolsmithPackageTests"
    ),
    .testTarget(
        name: "SSEOverMIDITests",
        dependencies: ["SSEOverMIDI", "MIDI2Transports", "MIDI2Core"],
        path: "Tests/SSEOverMIDITests"
    )
]

#if os(Linux)
products.append(.library(name: "PDFiumExtractor", targets: ["PDFiumExtractor"]))
targets.append(.target(name: "PDFiumExtractor", dependencies: [], path: "libs/PDFiumExtractor"))
#endif

let package = Package(
    name: "the-fountainai",
    platforms: [
        .macOS(.v14)
    ],
    products: products,
    dependencies: [
        .package(path: "./toolsmith"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.63.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/Fountain-Coach/midi2.git", from: "0.3.0")
    ],
    targets: targets
)

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
