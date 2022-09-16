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
            targets: ["Jetworking"]
        ),
        .library(
            name: "DataTransfer",
            targets: ["DataTransfer"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Jetworking"
        ),
        .target(
            name: "DataTransfer",
            dependencies: ["Jetworking"],
            path: "Modules/DataTransfer"
        ),
        .testTarget(
            name: "JetworkingTests",
            dependencies: ["Jetworking"]
        ),
        .testTarget(
            name: "DataTransferTests",
            dependencies: ["Jetworking", "DataTransfer"],
            resources: [
                .copy("Resources/avatar.png")
            ]
        ),
    ]
)
