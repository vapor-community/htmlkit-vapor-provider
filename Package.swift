// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTMLKitVaporProvider",
    platforms: [
      .macOS(.v10_15),
    ],

    products: [
        .library(
            name: "HTMLKitVaporProvider",
            targets: ["HTMLKitVaporProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor-community/HTMLKit.git", from: "2.0.0-beta.3"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "HTMLKitVaporProvider",
            dependencies: [
                "HTMLKit",
                "Vapor"
        ]),
        .testTarget(
            name: "HTMLKitVaporProviderTests",
            dependencies: ["HTMLKitVaporProvider"]),
    ]
)
