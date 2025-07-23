// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScreenplayGUI",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ScreenplayGUI", targets: ["ScreenplayGUI"])
    ],
    dependencies: [
        .package(path: "../../teatro")
    ],
    targets: [
        .executableTarget(
            name: "ScreenplayGUI",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ]
        ),
        .testTarget(
            name: "ScreenplayGUITests",
            dependencies: ["ScreenplayGUI", .product(name: "Teatro", package: "teatro")]
        )
    ]
)
