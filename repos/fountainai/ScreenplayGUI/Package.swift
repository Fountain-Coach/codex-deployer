// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var products: [Product] = [
    .library(name: "ScreenplayGUI", targets: ["ScreenplayGUI"]),
    .executable(name: "ScreenplayGUIApp", targets: ["ScreenplayGUIApp"])
]
#if os(macOS)
products.append(.executable(name: "PreviewHost", targets: ["PreviewHost"]))
#endif

var targets: [Target] = [
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
#if os(macOS)
targets.append(
    .executableTarget(
        name: "PreviewHost",
        dependencies: ["ScreenplayGUI", .product(name: "Teatro", package: "teatro")],
        path: "PreviewHost"
    )
)
#endif

let package = Package(
    name: "ScreenplayGUI",
    platforms: [.macOS(.v14)],
    products: products,
    dependencies: [
        .package(path: "../../teatro")
    ],
    targets: targets
)
