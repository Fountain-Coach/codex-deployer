// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TeatroPlayground",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "TeatroPlaygroundUI", targets: ["TeatroPlaygroundUI"]),
        .executable(name: "TeatroPlayground", targets: ["TeatroPlayground"])
    ],
    dependencies: [
        .package(url: "https://github.com/Fountain-Coach/teatro.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "TeatroPlaygroundUI",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
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
