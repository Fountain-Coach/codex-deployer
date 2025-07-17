// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SwiftCodexOpenAPIKernel",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "generator", targets: ["Generator"]),
        .executable(name: "baseline-awareness-server", targets: ["BaselineAwarenessServer"]),
        .executable(name: "bootstrap-server", targets: ["BootstrapServer"]),
        .executable(name: "persist-server", targets: ["PersistServer"]),
        .executable(name: "function-caller-server", targets: ["FunctionCallerServer"]),
        .executable(name: "planner-server", targets: ["PlannerServer"]),
        .executable(name: "tools-factory-server", targets: ["ToolsFactoryServer"]),
        .executable(name: "llm-gateway-server", targets: ["LLMGatewayServer"]),
        .executable(name: "SocketFixAgent", targets: ["SocketFixAgent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.63.0")
    ],
    targets: [
        .target(name: "Parser", dependencies: ["Yams"]),
        .target(name: "ModelEmitter", dependencies: ["Parser"]),
        .target(name: "ClientGenerator", dependencies: ["Parser"]),
        .target(name: "ServerGenerator", dependencies: ["Parser"]),
        .target(name: "ServiceShared", path: "Generated/Server/Shared"),
        // Generated service modules used for integration testing
        .target(
            name: "BaselineAwarenessService",
            dependencies: ["ServiceShared"],
            path: "Generated/Server/baseline-awareness",
            exclude: ["main.swift", "HTTPServer.swift", "Dockerfile"],
            sources: [
                "HTTPKernel.swift",
                "Router.swift",
                "Handlers.swift",
                "Models.swift",
                "HTTPRequest.swift",
                "HTTPResponse.swift",
                "BaselineStore.swift"
            ]
        ),
        .executableTarget(
            name: "BaselineAwarenessServer",
            dependencies: ["BaselineAwarenessService"],
            path: "Generated/Server/baseline-awareness",
            exclude: ["HTTPKernel.swift", "Router.swift", "Handlers.swift", "Models.swift", "HTTPRequest.swift", "HTTPResponse.swift", "BaselineStore.swift", "Dockerfile"],
            sources: ["main.swift", "HTTPServer.swift"]
        ),
        .target(name: "BaselineAwarenessClient", path: "Generated/Client/baseline-awareness"),
        .target(
            name: "BootstrapService",
            dependencies: ["ServiceShared", "BaselineAwarenessService"],
            path: "Generated/Server/bootstrap",
            exclude: ["main.swift", "Dockerfile"],
            sources: [
                "HTTPKernel.swift",
                "Router.swift",
                "Handlers.swift",
                "Models.swift",
                "HTTPRequest.swift",
                "HTTPResponse.swift"
            ]
        ),
        .executableTarget(
            name: "BootstrapServer",
            dependencies: ["BootstrapService"],
            path: "Generated/Server/bootstrap",
            exclude: ["HTTPKernel.swift", "Router.swift", "Handlers.swift", "Models.swift", "HTTPRequest.swift", "HTTPResponse.swift", "Dockerfile"],
            sources: ["main.swift"]
        ),
        .target(name: "BootstrapClient", path: "Generated/Client/bootstrap"),
        .target(
            name: "PersistService",
            dependencies: ["ServiceShared"],
            path: "Generated/Server/persist",
            exclude: ["main.swift", "Dockerfile"],
            sources: [
                "HTTPKernel.swift",
                "Router.swift",
                "Handlers.swift",
                "Models.swift",
                "HTTPRequest.swift",
                "HTTPResponse.swift"
            ]
        ),
        .executableTarget(
            name: "PersistServer",
            dependencies: ["PersistService"],
            path: "Generated/Server/persist",
            exclude: ["HTTPKernel.swift", "Router.swift", "Handlers.swift", "Models.swift", "HTTPRequest.swift", "HTTPResponse.swift", "Dockerfile"],
            sources: ["main.swift"]
        ),
        .target(name: "PersistClient", path: "Generated/Client/persist"),
        .target(
            name: "FunctionCallerService",
            dependencies: ["ServiceShared", "Parser"],
            path: "Generated/Server/function-caller",
            exclude: ["main.swift", "Dockerfile"],
            sources: [
                "HTTPKernel.swift",
                "Router.swift",
                "Handlers.swift",
                "Models.swift",
                "Dispatcher.swift",
                "HTTPRequest.swift",
                "HTTPResponse.swift",
                "Logger.swift"
            ]
        ),
        .executableTarget(
            name: "FunctionCallerServer",
            dependencies: ["FunctionCallerService"],
            path: "Generated/Server/function-caller",
            exclude: ["HTTPKernel.swift", "Router.swift", "Handlers.swift", "Models.swift", "Dispatcher.swift", "HTTPRequest.swift", "HTTPResponse.swift", "Logger.swift", "Dockerfile"],
            sources: ["main.swift"]
        ),
        .target(name: "FunctionCallerClient", path: "Generated/Client/function-caller"),
        .target(
            name: "PlannerService",
            dependencies: ["ServiceShared"],
            path: "Generated/Server/planner",
            exclude: ["main.swift", "Dockerfile"],
            sources: [
                "HTTPKernel.swift",
                "Router.swift",
                "Handlers.swift",
                "Models.swift",
                "LLMGatewayClient.swift",
                "LocalFunctionCallerClient.swift",
                "HTTPRequest.swift",
                "HTTPResponse.swift"
            ]
        ),
        .executableTarget(
            name: "PlannerServer",
            dependencies: ["PlannerService"],
            path: "Generated/Server/planner",
            exclude: ["HTTPKernel.swift", "Router.swift", "Handlers.swift", "Models.swift", "LLMGatewayClient.swift", "LocalFunctionCallerClient.swift", "HTTPRequest.swift", "HTTPResponse.swift", "Dockerfile"],
            sources: ["main.swift"]
        ),
        .target(name: "PlannerClient", path: "Generated/Client/planner"),
        .target(
            name: "ToolsFactoryService",
            dependencies: ["ServiceShared", "Parser"],
            path: "Generated/Server/tools-factory",
            exclude: ["main.swift", "Dockerfile"],
            sources: [
                "HTTPKernel.swift",
                "Router.swift",
                "Handlers.swift",
                "Models.swift",
                "HTTPRequest.swift",
                "HTTPResponse.swift"
            ]
        ),
        .executableTarget(
            name: "ToolsFactoryServer",
            dependencies: ["ToolsFactoryService"],
            path: "Generated/Server/tools-factory",
            exclude: ["HTTPKernel.swift", "Router.swift", "Handlers.swift", "Models.swift", "HTTPRequest.swift", "HTTPResponse.swift", "Dockerfile"],
            sources: ["main.swift"]
        ),
        .target(name: "ToolsFactoryClient", path: "Generated/Client/tools-factory"),
        .target(
            name: "LLMGatewayService",
            dependencies: ["ServiceShared"],
            path: "Generated/Server/llm-gateway",
            exclude: ["main.swift", "Dockerfile"],
            sources: [
                "HTTPKernel.swift",
                "Router.swift",
                "Handlers.swift",
                "Models.swift",
                "HTTPRequest.swift",
                "HTTPResponse.swift"
            ]
        ),
        .executableTarget(
            name: "LLMGatewayServer",
            dependencies: ["LLMGatewayService"],
            path: "Generated/Server/llm-gateway",
            exclude: ["HTTPKernel.swift", "Router.swift", "Handlers.swift", "Models.swift", "HTTPRequest.swift", "HTTPResponse.swift", "Dockerfile"],
            sources: ["main.swift"]
        ),
        .target(name: "LLMGatewayClientSDK", path: "Generated/Client/llm-gateway"),
        .target(
            name: "IntegrationRuntime",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio")
            ]
        ),
        .executableTarget(
            name: "SocketFixAgent",
            path: "Tools/Agents"
        ),
        .executableTarget(
            name: "Generator",
            dependencies: ["Parser", "ModelEmitter", "ClientGenerator", "ServerGenerator"]
        ),
        .testTarget(
            name: "GeneratorTests",
            dependencies: ["Generator"],
            resources: [.process("Fixtures")]
        ),
        .testTarget(name: "ServerTests", dependencies: ["ServerGenerator"]),
        .testTarget(name: "ParserTests", dependencies: ["Parser"]),
        .testTarget(name: "ClientGeneratorTests", dependencies: ["ClientGenerator", "Parser"]),
        .testTarget(
            name: "ModelEmitterTests",
            dependencies: ["ModelEmitter", "Parser"],
            resources: [.process("Fixtures")]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: [
                "IntegrationRuntime",
                "BaselineAwarenessService", "BaselineAwarenessClient",
                "BootstrapService", "BootstrapClient",
                "PersistService", "PersistClient",
                "FunctionCallerService", "FunctionCallerClient",
                "PlannerService", "PlannerClient",
                "ToolsFactoryService", "ToolsFactoryClient",
                "LLMGatewayService", "LLMGatewayClientSDK"
            ],
            resources: []
        )
    ]
)
