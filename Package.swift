// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Janet",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "Janet",
            targets: ["Janet"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/usami-k/SwiftLintPlugin", branch: "main")
    ],
    targets: [
        .target(
            name: "Janet",
            dependencies: [],
            plugins: [
                .plugin(name: "SwiftLintPlugin", package: "SwiftLintPlugin"),
            ]
        ),
        .testTarget(
            name: "JanetTests",
            dependencies: ["Janet"]
        )
    ]
)
