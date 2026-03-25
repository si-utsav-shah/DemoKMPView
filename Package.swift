// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DemoViewSDK",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "DemoViewSDK",
            targets: ["DemoViewSDK"]
        ),
    ],
    dependencies: [
        .package(path: "../KMPSDK"),
    ],
    targets: [
        .target(
            name: "DemoViewSDK",
            dependencies: [
                .product(name: "KMPSDK", package: "KMPSDK"),
            ]
        ),
    ]
)
