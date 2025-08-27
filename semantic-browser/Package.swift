// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SemanticBrowser",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SemanticBrowser",
            targets: ["SemanticBrowser"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Fountain-Coach/fountain-codex.git", branch: "main"),
        .package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "SemanticBrowser",
            dependencies: [
                "FountainCodex",
                .product(name: "Typesense", package: "typesense-swift")
            ]
        ),
        .testTarget(
            name: "SemanticBrowserTests",
            dependencies: [
                "SemanticBrowser",
                "FountainCodex"
            ]
        )
    ]
)
