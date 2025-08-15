import Foundation

/// SwiftPackageManagerKit provides tools for integrating with Swift Package Manager
public struct SwiftPackageManagerKit {
    
    /// The current version of SwiftPackageManagerKit
    public static let version = "1.0.0"
    
    private init() {}
    
    /// Test method to validate JSON parsing works
    public static func testJSONParsing(jsonData: Data) throws -> SPMPackageInfo {
        let decoder = JSONDecoder()
        return try decoder.decode(SPMPackageInfo.self, from: jsonData)
    }
    
    /// Test the full integration: ProcessRunner -> SPMExecutor -> SPMPackageInfo models
    public static func testIntegration() async throws -> (name: String, targetCount: Int, productCount: Int) {
        let executor = try SPMExecutor.current()
        let packageInfo = try await executor.dumpPackage()
        
        return (
            name: packageInfo.name,
            targetCount: packageInfo.targets.count,
            productCount: packageInfo.products.count
        )
    }
}