// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TeatroView",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TeatroView", targets: ["TeatroView"])
    ],
    dependencies: [
        .package(path: "../teatro")
    ],
    targets: [
        .executableTarget(
            name: "TeatroView",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/TeatroView"
        ),
        .testTarget(
            name: "TeatroViewTests",
            dependencies: ["TeatroView"],
            path: "Tests"
        )
    ]
)
