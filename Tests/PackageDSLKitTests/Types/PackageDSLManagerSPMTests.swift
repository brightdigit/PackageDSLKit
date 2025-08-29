import Foundation
import Testing

@testable import PackageDSLKit
@testable import SwiftPackageManagerKit

@Suite
struct PackageDSLManagerSPMTests {
  @Test(
    .disabled(
      if: ProcessInfo.processInfo.shouldDisableSPMValidation(),
      "SPM commands unreliable in GitHub CI via Xcode"
    ),
    .disabled(
      if: !Platform.allowsProcess,
      "Unable to run SPM commands in non-macOS platforms"
    )
  )
  func validateGeneratedPackageWithSPMValidation() async throws {
    dump(ProcessInfo.processInfo.environment)
    #if canImport(Foundation) && (os(macOS) || os(Linux))
      let tempDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("PackageDSLManagerTests-SPMValidation-\(UUID().uuidString)")
      let packageManager = await PackageDSLManager(
        packageURL: tempDirectory,
        packageName: "SPMValidationTest"
      )

      defer {
        if FileManager.default.fileExists(atPath: tempDirectory.path) {
          try? FileManager.default.removeItem(at: tempDirectory)
        }
      }

      try await setupPackageStructure(tempDirectory, packageManager)
      let spmExecutor = try await validateWithSPMCommands(tempDirectory)
      await validateCoexistenceOfFormats(packageManager)

    #else
      Issue.record("Unable to create and run a Process in this environment.")
    #endif
  }

  private func setupPackageStructure(
    _ tempDirectory: URL,
    _ packageManager: PackageDSLManager
  ) async throws {
    // Create package directory and Sources subdirectory
    try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    let sourcesDirectory = tempDirectory.appendingPathComponent("Sources/SPMValidationTest")
    try FileManager.default.createDirectory(
      at: sourcesDirectory, withIntermediateDirectories: true)

    // Create a simple Swift source file
    let sourceFile = sourcesDirectory.appendingPathComponent("SPMValidationTest.swift")
    try createSimpleSourceFile(at: sourceFile)

    // Configure a simple package without external dependencies for faster testing
    try await packageManager.createPackage(type: .library)

    // Create a Package.swift file that SPM can understand for testing SPM commands
    try createPackageSwiftFile(at: tempDirectory)
  }

  private func createSimpleSourceFile(at sourceFile: URL) throws {
    try """
    public struct SPMValidationTest {
        public init() {}

        public func hello() -> String {
            return "Hello, World!"
        }
    }
    """.write(to: sourceFile, atomically: true, encoding: .utf8)
  }

  private func createPackageSwiftFile(at tempDirectory: URL) throws {
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
  }

  private func validateWithSPMCommands(_ tempDirectory: URL) async throws -> Executor {
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

    return spmExecutor
  }

  private func validateCoexistenceOfFormats(_ packageManager: PackageDSLManager) async {
    // Test that our PackageDSLManager can detect the traditional Package.swift
    #expect(await packageManager.hasTraditionalPackageSwift())

    // Generate DSL files alongside the Package.swift
    do {
      try await packageManager.generatePackageSwift()
    } catch {
      Issue.record("Failed to generate DSL files: \(error)")
      return
    }

    // Verify both formats coexist
    #expect(await packageManager.hasTraditionalPackageSwift())
    #expect(await packageManager.hasDSLComponents())
  }
}
