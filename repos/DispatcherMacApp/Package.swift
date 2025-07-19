// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "DispatcherMacApp",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "DispatcherUI", targets: ["DispatcherUI"]),
        .executable(name: "DispatcherMacApp", targets: ["DispatcherMacApp"])
    ],
    dependencies: [
        .package(path: "../teatro")
    ],
    targets: [
        .target(
            name: "DispatcherUI",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/DispatcherUI"
        ),
        .executableTarget(
            name: "DispatcherMacApp",
            dependencies: [
                "DispatcherUI",
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/DispatcherMacApp"
        )
    ]
)
