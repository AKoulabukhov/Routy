// swift-tools-version:5.5
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
            name: "Routy"
        ),
        .target(
            name: "RoutyIOS",
            dependencies: ["Routy"]
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
