// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Jetworking",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "Jetworking",
            targets: ["Jetworking"]),
        .library(
            name: "(Up|Down)Loader",
            targets: ["(Up|Down)Loader"])
    ],
    targets: [
        .target(
            name: "Jetworking"
        ),
        .target(
            name: "(Up|Down)Loader",
            dependencies: ["Jetworking"],
            path: "Modules/(Up|Down)Loader"
        ),
        .testTarget(
            name: "JetworkingTests",
            dependencies: ["Jetworking", "(Up|Down)Loader"],
            resources: [
                .copy("Resources/avatar.png")
            ]
        ),
    ]
)
