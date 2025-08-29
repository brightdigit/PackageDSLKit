import Foundation
import Testing

@testable import PackageDSLKit

@Suite
internal struct PackageDSLManagerBasicTests {
  @Test
  internal func generatePackageSwiftCreatesFiles() async throws {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("PackageDSLManagerTests-\(UUID().uuidString)")
    let packageManager = await PackageDSLManager(
      packageURL: tempDirectory,
      packageName: "TestPackage"
    )

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
  internal func hasDSLComponentsReturnsFalseWhenNoFiles() async {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("PackageDSLManagerTests-\(UUID().uuidString)")
    let packageManager = await PackageDSLManager(
      packageURL: tempDirectory,
      packageName: "TestPackage"
    )

    defer {
      if FileManager.default.fileExists(atPath: tempDirectory.path) {
        try? FileManager.default.removeItem(at: tempDirectory)
      }
    }

    // For a directory without DSL files
    #expect(await packageManager.hasDSLComponents() == false)
  }

  @Test
  internal func hasTraditionalPackageSwiftDetectsFile() async throws {
    let tempDirectory = FileManager.default.temporaryDirectory
      .appendingPathComponent("PackageDSLManagerTests-\(UUID().uuidString)")
    let packageManager = await PackageDSLManager(
      packageURL: tempDirectory,
      packageName: "TestPackage"
    )

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
}
