import Foundation

/// Simple test utility for validating SPM models
public struct ModelValidator: Sendable {
  /// Test parsing JSON data with SPM models
  public static func validateJSON(_ jsonData: Data) throws -> PackageInfo {
    let decoder = JSONDecoder()
    return try decoder.decode(PackageInfo.self, from: jsonData)
  }

  /// Test round-trip encoding/decoding
  public static func validateRoundTrip(_ packageInfo: PackageInfo) throws -> Bool {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let encoded = try encoder.encode(packageInfo)
    let decoded = try decoder.decode(PackageInfo.self, from: encoded)

    return decoded == packageInfo
  }

  /// Create sample package info for testing
  public static func createSamplePackage() -> PackageInfo {
    let platform = Platform(platformName: "macos", version: "13.0")
    let toolsVersion = ToolsVersion(version: "6.0.0")
    let packageKind = PackageKind.root("/path/to/package")

    let product = Product(
      name: "TestLibrary",
      type: .library(.automatic),
      targets: ["TestTarget"]
    )

    let target = Target(
      name: "TestTarget",
      type: .regular,
      dependencies: [],
      exclude: [],
      resources: [],
      settings: [],
      packageAccess: true
    )

    return PackageInfo(
      name: "TestPackage",
      packageKind: packageKind,
      platforms: [platform],
      products: [product],
      dependencies: [],
      targets: [target],
      toolsVersion: toolsVersion
    )
  }
}
