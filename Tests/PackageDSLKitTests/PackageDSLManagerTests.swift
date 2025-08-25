import XCTest
import Foundation
@testable import PackageDSLKit

final class PackageDSLManagerTests: XCTestCase {
    
    var tempDirectory: URL!
    var packageManager: PackageDSLManager!
    
    override func setUp() async throws {
        try await super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PackageDSLManagerTests-\(UUID().uuidString)")
        packageManager = await PackageDSLManager(packageURL: tempDirectory, packageName: "TestPackage")
    }
    
    override func tearDown() {
        if FileManager.default.fileExists(atPath: tempDirectory.path) {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        super.tearDown()
    }
    
    func testGeneratePackageSwiftCreatesFiles() async throws {
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
        XCTAssertTrue(FileManager.default.fileExists(atPath: indexFile.path))
        
        // Verify the manager correctly detects DSL components
        XCTAssertTrue(await packageManager.hasDSLComponents())
    }
    
    func testHasDSLComponentsReturnsFalseWhenNoFiles() async {
        // For a directory without DSL files
        XCTAssertFalse(await packageManager.hasDSLComponents())
    }
    
    func testHasTraditionalPackageSwiftDetectsFile() async throws {
        // Create package directory
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        // Create a Package.swift file
        let packageSwiftFile = tempDirectory.appendingPathComponent("Package.swift")
        try "// swift-tools-version: 5.9\nimport PackageDescription\n\nlet package = Package(name: \"TestPackage\")".write(to: packageSwiftFile, atomically: true, encoding: .utf8)
        
        // Verify detection
        XCTAssertTrue(await packageManager.hasTraditionalPackageSwift())
    }
}