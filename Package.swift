// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "arrange-windows",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/dduan/TOMLDecoder", from: "0.2.2"),
    ],
    targets: [
        .executableTarget(
            name: "arrange-windows",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "TOMLDecoder", package: "TOMLDecoder"),
            ],
            path: "Sources/arrange-windows"
        ),
        .testTarget(
            name: "arrange-windowsTests",
            dependencies: ["arrange-windows"],
            path: "Tests/arrange-windowsTests"
        ),
    ]
)
