// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swiftlint:disable explicit_acl explicit_top_level_acl

import PackageDescription

let package = Package(
  name: "PackageDSLKit",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(name: "PackageDSLKit", targets: ["PackageDSLKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0-prerelease-2024-11-18"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.6.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "PackageDSLKit",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(
          name: "Logging",
          package: "swift-log",
          condition: .when(platforms: [.linux, .openbsd, .wasi, .android, .windows])
        )
      ],

      resources: [
        .copy("Resources/PackageDSL.swift.txt")
      ]
    ),
    .executableTarget(
      name: "package",
      dependencies: [
        "PackageDSLKit",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .testTarget(
      name: "PackageDSLKitTests",
      dependencies: ["PackageDSLKit"]
    )
  ]
)

// swiftlint:enable explicit_acl explicit_top_level_acl
