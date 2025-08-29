// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "OpenAPICurator",
    products: [
        .library(name: "OpenAPICurator", targets: ["OpenAPICurator"])
    ],
    targets: [
        .target(name: "OpenAPICurator"),
        .testTarget(name: "OpenAPICuratorTests", dependencies: ["OpenAPICurator"])
    ]
)
