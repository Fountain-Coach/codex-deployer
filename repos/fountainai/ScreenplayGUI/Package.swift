// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScreenplayGUI",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ScreenplayGUI", targets: ["ScreenplayGUI"]),
        .executable(name: "ScreenplayGUIApp", targets: ["ScreenplayGUIApp"])
    ],
    dependencies: [
        .package(path: "../../teatro")
    ],
    targets: [
        .target(
            name: "ScreenplayGUI",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ]
        ),
        .executableTarget(
            name: "ScreenplayGUIApp",
            dependencies: ["ScreenplayGUI"]
        ),
        .testTarget(
            name: "ScreenplayGUITests",
            dependencies: ["ScreenplayGUI", .product(name: "Teatro", package: "teatro")]
        )
    ]
)
