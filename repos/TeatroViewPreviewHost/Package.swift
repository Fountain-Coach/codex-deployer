// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TeatroViewPreviewHost",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TeatroViewPreviewHost", targets: ["TeatroViewPreviewHost"])
    ],
    dependencies: [
        .package(path: "../TeatroView")
    ],
    targets: [
        .executableTarget(
            name: "TeatroViewPreviewHost",
            dependencies: ["TeatroView"],
            path: "Sources/TeatroViewPreviewHost"
        )
    ]
)
