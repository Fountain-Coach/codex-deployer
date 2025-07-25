// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "teatro",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "Teatro",
            targets: ["Teatro"]
        ),
        .executable(name: "RenderCLI", targets: ["RenderCLI"])
    ],
    targets: [
        .target(
            name: "Teatro",
            path: "Sources",
            exclude: ["CLI"]
        ),
        .executableTarget(
            name: "RenderCLI",
            dependencies: ["Teatro"],
            path: "Sources/CLI"
        ),
        .testTarget(
            name: "TeatroTests",
            dependencies: ["Teatro"],
            path: "Tests",
            exclude: ["StoryboardDSLTests", "MIDITests", "RendererFileTests"]
        ),
        .testTarget(
            name: "StoryboardDSLTests",
            dependencies: ["Teatro"],
            path: "Tests/StoryboardDSLTests"
        ),
        .testTarget(
            name: "MIDITests",
            dependencies: ["Teatro"],
            path: "Tests/MIDITests"
        ),
        .testTarget(
            name: "RendererFileTests",
            dependencies: ["Teatro"],
            path: "Tests/RendererFileTests"
        )
    ]
)
