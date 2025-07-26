// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TeatroPlayground",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "TeatroPlaygroundUI", targets: ["TeatroPlaygroundUI"]),
        .library(name: "TeatroPlaygroundCore", targets: ["TeatroPlaygroundCore"]),
        .executable(name: "TeatroPlayground", targets: ["TeatroPlayground"])
    ],
    dependencies: [
        .package(url: "https://github.com/fountain-coach/teatro.git", branch: "main")
    ],
    targets: [
        .target(
            name: "TeatroPlaygroundCore",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/TeatroPlaygroundCore"
        ),
        .target(
            name: "TeatroPlaygroundUI",
            dependencies: [
                .product(name: "Teatro", package: "teatro"),
                "TeatroPlaygroundCore"
            ],
            path: "Sources/TeatroPlaygroundUI"
        ),
        .executableTarget(
            name: "TeatroPlayground",
            dependencies: [
                "TeatroPlaygroundUI",
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/TeatroPlayground"
        ),
        .testTarget(
            name: "TeatroPlaygroundTests",
            dependencies: ["TeatroPlaygroundUI"],
            path: "Tests"
        )
    ]
)
