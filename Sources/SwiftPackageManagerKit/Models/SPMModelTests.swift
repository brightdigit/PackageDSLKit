import Foundation

/// Simple test utility for validating SPM models
public struct SPMModelValidator {
    
    /// Test parsing JSON data with SPM models
    public static func validateJSON(_ jsonData: Data) throws -> SPMPackageInfo {
        let decoder = JSONDecoder()
        return try decoder.decode(SPMPackageInfo.self, from: jsonData)
    }
    
    /// Test round-trip encoding/decoding
    public static func validateRoundTrip(_ packageInfo: SPMPackageInfo) throws -> Bool {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let encoded = try encoder.encode(packageInfo)
        let decoded = try decoder.decode(SPMPackageInfo.self, from: encoded)
        
        return decoded == packageInfo
    }
    
    /// Create sample package info for testing
    public static func createSamplePackage() -> SPMPackageInfo {
        let platform = SPMPlatform(platformName: "macos", version: "13.0")
        let toolsVersion = SPMToolsVersion(version: "6.0.0")
        let packageKind = SPMPackageKind.root("/path/to/package")
        
        let product = SPMProduct(
            name: "TestLibrary",
            type: .library(.automatic),
            targets: ["TestTarget"]
        )
        
        let target = SPMTarget(
            name: "TestTarget",
            type: .regular,
            dependencies: [],
            exclude: [],
            resources: [],
            settings: [],
            packageAccess: true
        )
        
        return SPMPackageInfo(
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