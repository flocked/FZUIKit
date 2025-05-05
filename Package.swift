// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FZUIKit",
    platforms: [.macOS(.v10_15), .iOS(.v14), .tvOS(.v14), .macCatalyst(.v14), .watchOS(.v6)],
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
        .target(
            name: "FZUIKit",
            dependencies: ["FZSwiftUtils", "_DelegateProxy", "_ObjectProxy"],
            resources: [
                .process("Resources"),
            ]            
        ),
        .target(name: "_DelegateProxy",
                path: "Sources/FZUIKit+ObjC/DelegateProxy"),
        .target(name: "_ObjectProxy",
                path: "Sources/FZUIKit+ObjC/ObjectProxy"),
    ]
)
