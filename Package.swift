// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PackageDSLKit",
    platforms: [
        .macOS(.v10_15)
      ],
    dependencies: [
       .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0-prerelease-2024-11-18")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "package",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
              ]
        ),
    ]
)
