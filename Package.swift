// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NestedTable",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NestedTable",
            targets: ["NestedTable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/anconaesselmann/CoreDataStored", from: "0.0.7")
    ],
    targets: [
        .target(
            name: "NestedTable",
            dependencies: ["CoreDataStored"]
        ),
    ]
)
