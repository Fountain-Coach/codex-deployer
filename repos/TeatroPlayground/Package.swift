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
        .package(path: "../teatro")
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
                "TeatroPlaygroundUI"
            ],
            path: "Sources/TeatroPlayground"
        )
    ]
)
