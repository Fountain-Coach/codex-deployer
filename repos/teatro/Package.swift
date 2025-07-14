// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Teatro",
    products: [
        .library(name: "Teatro", targets: ["Teatro"]),
        .executable(name: "RenderCLI", targets: ["RenderCLI"])
    ],
    targets: [
        .target(name: "Teatro", path: "Sources", exclude: ["CLI"]),
        .executableTarget(name: "RenderCLI", dependencies: ["Teatro"], path: "Sources/CLI"),
        .testTarget(name: "TeatroTests", dependencies: ["Teatro"], path: "Tests")
    ]
)
