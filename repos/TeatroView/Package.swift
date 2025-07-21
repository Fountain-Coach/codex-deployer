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
        .executableTarget(
            name: "TeatroView",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/TeatroView"
        ),
        .target(
            name: "TypesenseClient",
            path: "Sources/TypesenseClient"
        ),
        .testTarget(
            name: "TeatroViewTests",
            dependencies: ["TeatroView"],
            path: "Tests"
        )
    ]
)
