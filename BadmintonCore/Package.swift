// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BadmintonCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BadmintonCore",
            targets: ["BadmintonCore"]),
    ],
    targets: [
        .target(
            name: "BadmintonCore",
            dependencies: []),
        .testTarget(
            name: "BadmintonCoreTests",
            dependencies: ["BadmintonCore"]),
    ]
)
