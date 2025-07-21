// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "TypesenseClient",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "TypesenseClient", targets: ["TypesenseClient"])
    ],
    targets: [
        .target(name: "TypesenseClient", path: "Sources"),
        .testTarget(name: "TypesenseClientTests", dependencies: ["TypesenseClient"], path: "Tests")
    ]
)
