// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModuleB",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "ModuleB",
            targets: ["ModuleB"]
        ),
        // Our protocol module
        .library(
            name: "ModuleBProtocol",
            targets: ["ModuleBProtocol"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        // Our protocol target
        .target(name: "ModuleBProtocol"),
        .target(
            name: "ModuleB",
            dependencies: ["ModuleBProtocol"] // ModuleB's dependency on the protocol target
        ),
        .testTarget(
            name: "ModuleBTests",
            dependencies: ["ModuleB"]
        ),
    ]
)
