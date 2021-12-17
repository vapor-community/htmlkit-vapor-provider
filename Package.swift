// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTMLKitVaporProvider",
    platforms: [
      .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "HTMLKitVaporProvider", targets: ["HTMLKitVaporProvider"]),
    ],
    dependencies: [
        .package(name: "HTMLKit", url: "https://github.com/vapor-community/HTMLKit.git", from: "2.4.0"),
        .package(name: "vapor", url: "https://github.com/vapor/vapor.git", from: "4.54.0")
    ],
    targets: [
        .target(
            name: "HTMLKitVaporProvider",
            dependencies: [
                .product(name: "HTMLKit", package: "HTMLKit"),
                .product(name: "Vapor", package: "vapor")
            ]),
        .testTarget(
            name: "HTMLKitVaporProviderTests",
            dependencies: [
                .target(name: "HTMLKitVaporProvider"),
                .product(name: "XCTVapor", package: "vapor")
            ]),
    ]
)
