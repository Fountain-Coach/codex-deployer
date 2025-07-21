// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TeatroView",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TeatroView", targets: ["TeatroView"]),
        .library(name: "TypesenseClient", targets: ["TypesenseClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/fountain-coach/teatro.git", branch: "main")
    ],
    targets: [
        .target(
            name: "TeatroViewCore",
            dependencies: ["TypesenseClient"],
            path: "Sources/TeatroView",
            exclude: ["main.swift"],
            resources: []
        ),
        .executableTarget(
            name: "TeatroView",
            dependencies: [
                "TeatroViewCore",
                "TypesenseClient",
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/TeatroView",
            sources: ["main.swift"]
        ),
        .target(
            name: "TypesenseClient",
            path: "Sources/TypesenseClient"
        ),
        .testTarget(
            name: "TeatroViewTests",
            dependencies: ["TeatroViewCore"],
            path: "Tests"
        )
    ]
)
