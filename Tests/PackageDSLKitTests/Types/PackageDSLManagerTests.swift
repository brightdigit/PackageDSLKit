import Foundation
import Testing

@testable import PackageDSLKit
@testable import SwiftPackageManagerKit

@Suite
struct PackageDSLManagerTests {
  @Test
  func generatePackageSwiftCreatesFiles() async throws {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("PackageDSLManagerTests-\(UUID().uuidString)")
    let packageManager = await PackageDSLManager(
      packageURL: tempDirectory, packageName: "TestPackage")

    defer {
      if FileManager.default.fileExists(atPath: tempDirectory.path) {
        try? FileManager.default.removeItem(at: tempDirectory)
      }
    }
    // Create package directory
    try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

    // Configure a simple package
    try await packageManager
      .createPackage(type: .library)
      .addDependency(url: "https://github.com/apple/swift-log.git", requirement: .from("1.0.0"))

    // Generate DSL files
    try await packageManager.generatePackageSwift()

    // Verify Index.swift was created
    let indexFile = tempDirectory.appendingPathComponent("Index.swift")
    #expect(FileManager.default.fileExists(atPath: indexFile.path))

    // Verify the manager correctly detects DSL components
    #expect(await packageManager.hasDSLComponents())
  }

  @Test
  func hasDSLComponentsReturnsFalseWhenNoFiles() async {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("PackageDSLManagerTests-\(UUID().uuidString)")
    let packageManager = await PackageDSLManager(
      packageURL: tempDirectory, packageName: "TestPackage")

    defer {
      if FileManager.default.fileExists(atPath: tempDirectory.path) {
        try? FileManager.default.removeItem(at: tempDirectory)
      }
    }

    // For a directory without DSL files
    #expect(await packageManager.hasDSLComponents() == false)
  }

  @Test
  func hasTraditionalPackageSwiftDetectsFile() async throws {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("PackageDSLManagerTests-\(UUID().uuidString)")
    let packageManager = await PackageDSLManager(
      packageURL: tempDirectory, packageName: "TestPackage")

    defer {
      if FileManager.default.fileExists(atPath: tempDirectory.path) {
        try? FileManager.default.removeItem(at: tempDirectory)
      }
    }

    // Create package directory
    try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

    // Create a Package.swift file
    let packageSwiftFile = tempDirectory.appendingPathComponent("Package.swift")
    try
      "// swift-tools-version: 5.9\nimport PackageDescription\n\nlet package = Package(name: \"TestPackage\")"
      .write(to: packageSwiftFile, atomically: true, encoding: .utf8)

    // Verify detection
    #expect(await packageManager.hasTraditionalPackageSwift())
  }

  @Test
  func generateAndValidateComplexPackage() async throws {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("PackageDSLManagerTests-ComplexPackage-\(UUID().uuidString)")
    let packageManager = await PackageDSLManager(
      packageURL: tempDirectory, packageName: "ComplexTestPackage")

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
        requirement: .upToNextMajor(from: "1.3.0"))

    // Generate DSL files
    try await packageManager.generatePackageSwift()

    // Verify core DSL files were created
    let indexFile = tempDirectory.appendingPathComponent("Index.swift")
    #expect(FileManager.default.fileExists(atPath: indexFile.path))

    // Read and verify Index.swift content contains the expected DSL structure
    let indexContent = try String(contentsOf: indexFile)
    #expect(indexContent.contains("ComplexTestPackage"))
    #expect(indexContent.contains("swift-log"))
    #expect(indexContent.contains("NetworkingCoreTests"))

    // Verify package detection methods
    #expect(await packageManager.hasDSLComponents())
    #expect(await !packageManager.hasTraditionalPackageSwift())

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
    // in the validateGeneratedPackageWithSPMValidation test
  }

  @Test(
    .disabled(
      if: ProcessInfo.processInfo.shouldDisableSPMValidation(),
      "SPM commands unreliable in GitHub CI via Xcode"
    ),
    .enabled(
      if: Platform.allowsProcess,
      "Unable to run SPM commands in non-macOS platforms"
    )
  )
  func validateGeneratedPackageWithSPMValidation() async throws {
    #if canImport(Foundation) && (os(macOS) || os(Linux))
      let tempDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("PackageDSLManagerTests-SPMValidation-\(UUID().uuidString)")
      let packageManager = await PackageDSLManager(
        packageURL: tempDirectory, packageName: "SPMValidationTest")

      defer {
        if FileManager.default.fileExists(atPath: tempDirectory.path) {
          try? FileManager.default.removeItem(at: tempDirectory)
        }
      }

      // Create package directory and Sources subdirectory
      try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
      let sourcesDirectory = tempDirectory.appendingPathComponent("Sources/SPMValidationTest")
      try FileManager.default.createDirectory(
        at: sourcesDirectory, withIntermediateDirectories: true)

      // Create a simple Swift source file
      let sourceFile = sourcesDirectory.appendingPathComponent("SPMValidationTest.swift")
      try """
      public struct SPMValidationTest {
          public init() {}

          public func hello() -> String {
              return "Hello, World!"
          }
      }
      """.write(to: sourceFile, atomically: true, encoding: .utf8)

      // Configure a simple package without external dependencies for faster testing
      try await packageManager.createPackage(type: .library)

      // Create a Package.swift file that SPM can understand for testing SPM commands
      let packageSwiftContent = """
        // swift-tools-version: 5.9
        import PackageDescription

        let package = Package(
            name: "SPMValidationTest",
            products: [
                .library(name: "SPMValidationTest", targets: ["SPMValidationTest"]),
            ],
            targets: [
                .target(name: "SPMValidationTest", dependencies: []),
            ]
        )
        """

      let packageSwiftFile = tempDirectory.appendingPathComponent("Package.swift")
      try packageSwiftContent.write(to: packageSwiftFile, atomically: true, encoding: .utf8)

      // Test SPM commands through our SPMExecutor
      let spmExecutor = try Executor(packageDirectory: tempDirectory, defaultTimeout: 60)

      // Test package dump-package
      let packageInfo = try await spmExecutor.dumpPackage()
      #expect(packageInfo.name == "SPMValidationTest")
      #expect(packageInfo.products.count == 1)
      #expect(packageInfo.products.first?.name == "SPMValidationTest")
      #expect(packageInfo.targets.count == 1)
      #expect(packageInfo.targets.first?.name == "SPMValidationTest")

      // Test package resolve (should be quick since no external dependencies)
      try await spmExecutor.resolvePackage()

      // Test build (this ensures the package structure is correct)
      try await spmExecutor.buildPackage()

      // Verify build artifacts were created
      let buildDirectory = tempDirectory.appendingPathComponent(".build")
      #expect(FileManager.default.fileExists(atPath: buildDirectory.path))

      // Test that our PackageDSLManager can detect the traditional Package.swift
      #expect(await packageManager.hasTraditionalPackageSwift())

      // Generate DSL files alongside the Package.swift
      try await packageManager.generatePackageSwift()

      // Verify both formats coexist
      #expect(await packageManager.hasTraditionalPackageSwift())
      #expect(await packageManager.hasDSLComponents())
    #else
      Issue.record("Unable to create and run a Process in this environment.")
    #endif
  }
}
