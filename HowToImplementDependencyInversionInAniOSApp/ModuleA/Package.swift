// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModuleA",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "ModuleA",
            targets: ["ModuleA"]
        ),
    ],
    dependencies: [
        .package(path: "../ModuleB"),
    ],
    targets: [
        .target(
            name: "ModuleA",
            dependencies: [
                .product(name: "ModuleBProtocol", package: "ModuleB")
            ]
        ),
        .testTarget(
            name: "ModuleATests",
            dependencies: ["ModuleA"]
        ),
    ]
)
