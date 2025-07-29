// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TeatroPreviewUI",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "TeatroPreviewUI", targets: ["TeatroPreviewUI"])
    ],
    dependencies: [
        .package(path: "../teatro")
    ],
    targets: [
        .target(
            name: "TeatroPreviewUI",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TeatroPreviewUITests",
            dependencies: ["TeatroPreviewUI"],
            path: "Tests"
        )
    ]
)
