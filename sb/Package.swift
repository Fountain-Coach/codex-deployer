// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SemanticBrowser",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "sb", targets: ["SBCLI"]),
        .library(name: "SBCore", targets: ["SBCore"])
    ],
    targets: [
        .executableTarget(
            name: "SBCLI",
            dependencies: ["SBCore"]
        ),
        .target(name: "SBCore"),
        .testTarget(
            name: "SBCoreTests",
            dependencies: ["SBCore"],
            resources: [
                .copy("Golden")
            ]
        )
    ]
)
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
