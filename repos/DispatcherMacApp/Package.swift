// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "DispatcherMacApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DispatcherMacApp", targets: ["DispatcherMacApp"])
    ],
    dependencies: [
        .package(path: "../teatro")
    ],
    targets: [
        .executableTarget(
            name: "DispatcherMacApp",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources"
        )
    ]
)
