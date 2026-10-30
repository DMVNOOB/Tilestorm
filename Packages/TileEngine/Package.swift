// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TileEngine",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "TileEngine", targets: ["TileEngine"]),
    ],
    targets: [
        .target(
            name: "TileEngine",
            exclude: ["Resources/README.md"],
            resources: [.copy("Resources/enable1.txt")]
        ),
        .testTarget(name: "TileEngineTests", dependencies: ["TileEngine"]),
    ]
)
