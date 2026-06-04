// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IntervalTimer",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "IntervalTimer",
            targets: ["IntervalTimer"]),
    ],
    targets: [
        .target(
            name: "IntervalTimer",
            dependencies: [],
            path: "IntervalTimer",
            resources: [
                .process("Resources")
            ]
        )
    ]
)

// Made with Bob
