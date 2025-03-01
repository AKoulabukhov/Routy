// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Routy",
    products: [
        .library(
            name: "Routy",
            targets: ["Routy"]
        ),
        .library(
            name: "RoutyIOS",
            targets: ["RoutyIOS"]
        ),
    ],
    targets: [
        .target(
            name: "Routy",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .target(
            name: "RoutyIOS",
            dependencies: ["Routy"],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "RoutyTests",
            dependencies: ["Routy"]
        ),
        .testTarget(
            name: "RoutyIOSTests",
            dependencies: ["RoutyIOS"]
        ),
    ]
)
