// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "teatro",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "Teatro",
            targets: ["Teatro"]
        ),
        .executable(name: "RenderCLI", targets: ["RenderCLI"])
    ],
    targets: [
        .target(
            name: "Teatro",
            path: "Sources",
            exclude: ["CLI"]
        ),
        .executableTarget(
            name: "RenderCLI",
            dependencies: ["Teatro"],
            path: "Sources/CLI"
        )
    ]
)
