import Foundation
import Testing

@testable import PackageDSLKit

@Suite
internal struct PackageDSLManagerComplexTests {
  @Test
  internal func generateAndValidateComplexPackage() async throws {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("PackageDSLManagerTests-ComplexPackage-\(UUID().uuidString)")
    let packageManager = await PackageDSLManager(
      packageURL: tempDirectory,
      packageName: "ComplexTestPackage"
    )

    defer {
      if FileManager.default.fileExists(atPath: tempDirectory.path) {
        try? FileManager.default.removeItem(at: tempDirectory)
      }
    }

    // Create package directory
    try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

    // Configure a complex package with multiple targets, products, and dependencies
    try await packageManager
      .createPackage(type: .library)
      .addTarget(name: "NetworkingCore", type: .library, dependencies: [])
      .addTarget(
        name: "NetworkingCoreTests", type: .test,
        dependencies: [DependencyRef(name: "NetworkingCore")]
      )
      .addTarget(
        name: "CLI", type: .executable, dependencies: [DependencyRef(name: "NetworkingCore")]
      )
      .addProduct(name: "NetworkingCore", type: .library, targets: ["NetworkingCore"])
      .addProduct(name: "CLI", type: .executable, targets: ["CLI"])
      .addDependency(url: "https://github.com/apple/swift-log.git", requirement: .from("1.5.0"))
      .addDependency(
        url: "https://github.com/apple/swift-argument-parser.git",
        requirement: .upToNextMajor(from: "1.3.0")
      )

    // Generate DSL files
    try await packageManager.generatePackageSwift()

    try await validateComplexPackageGeneration(packageManager, tempDirectory)
    await validatePackageDetection(packageManager)
    await validateTraditionalPackageGeneration(packageManager)
  }

  private func validateComplexPackageGeneration(
    _ _: PackageDSLManager,
    _ tempDirectory: URL
  ) async throws {
    // Verify core DSL files were created
    let indexFile = tempDirectory.appendingPathComponent("Index.swift")
    #expect(FileManager.default.fileExists(atPath: indexFile.path))

    // Read and verify Index.swift content contains the expected DSL structure
    let indexContent = try String(contentsOf: indexFile)
    #expect(indexContent.contains("ComplexTestPackage"))
    #expect(indexContent.contains("swift-log"))
    #expect(indexContent.contains("NetworkingCoreTests"))
  }

  private func validatePackageDetection(_ packageManager: PackageDSLManager) async {
    // Verify package detection methods
    #expect(await packageManager.hasDSLComponents())
    #expect(await !packageManager.hasTraditionalPackageSwift())
  }

  private func validateTraditionalPackageGeneration(_ packageManager: PackageDSLManager) async {
    // Test that traditional Package.swift generation works correctly
    let generatedPackageSwift = await packageManager.generateTraditionalPackageSwift()
    #expect(generatedPackageSwift.contains("ComplexTestPackage"))
    #expect(generatedPackageSwift.contains("NetworkingCore"))
    #expect(generatedPackageSwift.contains("CLI"))
    #expect(generatedPackageSwift.contains("swift-log.git"))
    #expect(generatedPackageSwift.contains("swift-argument-parser.git"))
    #expect(generatedPackageSwift.contains("testTarget"))

    // Note: Full SPM validation would require proper directory structure with Sources/
    // The core functionality is validated above, and detailed SPM integration is tested
    // in the SPM validation tests
  }
}
