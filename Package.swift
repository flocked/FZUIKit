// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FZUIKit",
    platforms: [.macOS("10.15.1"), .iOS(.v14), .macCatalyst(.v14), .tvOS(.v14), .watchOS(.v6)],
    products: [
        .library(
            name: "FZUIKit",
            targets: ["FZUIKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/flocked/FZSwiftUtils.git", branch: "main"),
    ],
    targets: [
        .target(name: "_DelegateProxyObjC"),
        .target(
            name: "FZUIKit",
            dependencies: ["FZSwiftUtils", "_DelegateProxyObjC"],
            resources: [
                .process("Resources"),
            ]            
        ),
    ]
)
