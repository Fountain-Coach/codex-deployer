// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "TeatroView",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "TeatroUI",
      targets: ["TeatroUI"]
    ),
    .executable(
      name: "TeatroApp",
      targets: ["TeatroApp"]
    )
  ],
  dependencies: [
    .package(name: "Teatro", path: "../teatro"),
    .package(name: "TypesenseClient", path: "../TypesenseClient")
  ],
  targets: [
    .target(
      name: "TeatroUI",
      dependencies: ["Teatro", "TypesenseClient"]
    ),
    .executableTarget(
      name: "TeatroApp",
      dependencies: ["TeatroUI"]
    ),
    .testTarget(
      name: "TeatroUITests",
      dependencies: ["TeatroUI"]
    )
  ]
)
