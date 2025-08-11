// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SPS",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "sps", targets: ["SPSCLI"]),
    ],
    targets: [
        .executableTarget(
            name: "SPSCLI",
            path: "Sources/SPSCLI",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SPSCLITests",
            dependencies: ["SPSCLI"],
            path: "Tests/SPSCLITests"
        )
    ]
)
