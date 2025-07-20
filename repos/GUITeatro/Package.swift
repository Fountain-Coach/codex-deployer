// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "GUITeatro",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "GUITeatroUI", targets: ["GUITeatroUI"]),
        .executable(name: "GUITeatro", targets: ["GUITeatro"])
    ],
    dependencies: [
        .package(path: "../teatro")
    ],
    targets: [
        .target(
            name: "GUITeatroUI",
            dependencies: [
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/GUITeatroUI"
        ),
        .executableTarget(
            name: "GUITeatro",
            dependencies: [
                "GUITeatroUI",
                .product(name: "Teatro", package: "teatro")
            ],
            path: "Sources/GUITeatro"
        )
    ]
)
