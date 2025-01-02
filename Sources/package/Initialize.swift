//
//  Initialize.swift
//  PackageDSLKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import ArgumentParser
import Foundation
import PackageDSLKit

extension Package {
  internal struct Initialize: ParsableCommand {
    internal enum PackageType: String, ExpressibleByArgument {
      case empty
      case library
      case executable
    }

    @OptionGroup internal var settings: Settings

    @Option
    internal var name: String?

    @Option
    internal var swiftVersion: SwiftVersion = "6.0"

    @Option
    internal var packageType: PackageType = .empty

    internal var packageName: String {
      self.name ?? self.settings.pathURL.lastPathComponent
    }

    internal var shouldCreateDirectory: Bool {
      self.settings.path != nil
    }

    internal static let configuration: CommandConfiguration = .init(
      commandName: "init"
    )

    private var productName: String {
      name ?? settings.rootName
    }

    internal static func createFileStructure(
      forPackageType packageType: PackageType,
      withFileManager fileManager: FileManager,
      forProductName productName: String,
      at pathURL: URL
    ) throws {
      guard packageType != .empty else {
        return
      }

      let sourcesDirURL = pathURL.appendingPathComponent("Sources/\(productName)")
      try fileManager.createDirectory(at: sourcesDirURL, withIntermediateDirectories: true)
      let sourceCode: String
      let fileName: String
      switch packageType {
      case .empty:
        assertionFailure()
        return
      case .library:
        sourceCode = """
          // The Swift Programming Language
          // https://docs.swift.org/swift-book
          """
        fileName = "\(productName).swift"
      case .executable:
        fileName = "main.swift"
        sourceCode = """
          // The Swift Programming Language
          // https://docs.swift.org/swift-book

          print("Hello, world!")
          """
      }

      fileManager.createFile(
        atPath: sourcesDirURL.appendingPathComponent(fileName).path(),
        contents: Data(sourceCode.utf8)
      )

      guard packageType == .library else {
        return
      }

      let testingDirURL = pathURL.appendingPathComponent("Tests/\(productName)Tests")
      try fileManager.createDirectory(at: testingDirURL, withIntermediateDirectories: true)

      let testFileURL = testingDirURL.appendingPathComponent("\(productName)Tests.swift")
      let testCode = """
        import Testing
        @testable import \(productName)

        @Test func example() async throws {
            // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        }
        """
      fileManager.createFile(atPath: testFileURL.path(), contents: Data(testCode.utf8))
    }
    internal static func writePackageSwiftFile(
      withFileManager fileManager: FileManager,
      swiftVersion: SwiftVersion,
      from dslSourcesURL: URL,
      to pathURL: URL
    ) throws {
      let contents = try fileManager.readDirectoryContents(
        at: dslSourcesURL.path(),
        fileExtension: "swift"
      )
      
      let packageFileURL = pathURL.appendingPathComponent("Package.swift")
      let strings =
      [
        "// swift-tools-version: \(swiftVersion)",
        SupportCodeBlock.syntaxNode.trimmedDescription,
      ] + contents
      let data = strings.joined(separator: "\n").data(using: .utf8)!
      fileManager.createFile(atPath: packageFileURL.path(), contents: data)
    }
    
    internal func run() throws {
      if shouldCreateDirectory {
        try self.settings.fileManager.createDirectory(
          at: self.settings.dslSourcesURL,
          withIntermediateDirectories: true,
          attributes: nil
        )
      }

      let spec = PackageSpecifications(name: name ?? settings.rootName, type: self.packageType)
      let writer = PackageWriter()
      try writer.write(spec, to: self.settings.dslSourcesURL)
      print("Written to:", "\(self.settings.pathURL.standardizedFileURL.path())")

      let swiftVersionFile = settings.pathURL.appending(component: ".swift-version")
      settings.fileManager.createFile(atPath: swiftVersionFile.path(), contents: Data("\(self.swiftVersion)".utf8))
      try! Self.writePackageSwiftFile(withFileManager: settings.fileManager, swiftVersion: swiftVersion, from: settings.dslSourcesURL, to: settings.pathURL)
      print(settings.pathURL)
      
      try! Self.createFileStructure(forPackageType: packageType, withFileManager: settings.fileManager, forProductName: productName, at: settings.pathURL)
    }
  }
}
