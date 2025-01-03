//
//  FileManager.swift
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

import Foundation

extension FileManager: PackageFilesInterface {
  public var currentDirectoryURL: URL {
    URL(fileURLWithPath: currentDirectoryPath)
  }

  private func readDirectoryContents(at path: String, fileExtension: String = "swift") throws
    -> [String]
  {
    var contents: [String] = []
    let items = try contentsOfDirectory(atPath: path)

    // Process subdirectories (post-order)
    for item in items {
      let itemPath = (path as NSString).appendingPathComponent(item)
      var isDirectory: ObjCBool = false
      let fileExists = fileExists(atPath: itemPath, isDirectory: &isDirectory)

      if fileExists && isDirectory.boolValue {
        contents += try readDirectoryContents(at: itemPath, fileExtension: fileExtension)
      }
    }

    // Process files
    for item in items where item.hasSuffix(".\(fileExtension)") {
      let itemPath = (path as NSString).appendingPathComponent(item)

      let fileContents = try String(contentsOfFile: itemPath, encoding: .utf8)
      contents.append(fileContents)
    }

    return contents
  }
  public func writePackageSwiftFile(
    swiftVersion: SwiftVersion,
    from dslSourcesURL: URL,
    to pathURL: URL
  ) throws {
    let contents = try self.readDirectoryContents(
      at: dslSourcesURL.path(),
      fileExtension: "swift"
    )

    let packageFileURL = pathURL.appendingPathComponent("Package.swift")
    let strings =
      [
        "// swift-tools-version: \(swiftVersion)",
        SupportCodeBlock.syntaxNode.trimmedDescription,
      ] + contents
    let data = Data(strings.joined(separator: "\n").utf8)
    self.createFile(atPath: packageFileURL.path(), contents: data)
    // TODO: log error if file creation fails
  }

  public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool)
    throws
  {
    try self.createDirectory(
      at: url,
      withIntermediateDirectories: createIntermediates,
      attributes: nil
    )
  }

  public func createFile(at url: URL, text: String) {
    self.createFile(atPath: url.path(), contents: Data(text.utf8))
  }
  public func swiftVersion(from directoryURL: URL) -> SwiftVersion? {
    let swiftVersionURL = directoryURL.appending(component: ".swift-version")
    let packageSwiftURL = directoryURL.appending(component: "Package.swift")

    let swiftVersionText: String?
    do {
      swiftVersionText = try String(contentsOf: swiftVersionURL)
    } catch {
      // TODO: log error if file exists
      // TODO: Assertion failure too
      swiftVersionText = nil
    }

    let swiftVersion = swiftVersionText.flatMap(SwiftVersion.init(stringLiteral:))

    if let swiftVersion {
      return swiftVersion
    }

    return .readFrom(packageSwiftFileURL: packageSwiftURL)
  }
  public func createTargetSourceAt(
    _ pathURL: URL, productName: String, _ productType: ProductType
  ) throws {
    let sourcesDirURL = pathURL.appendingPathComponent("Sources/\(productName)")
    try self.createDirectory(at: sourcesDirURL, withIntermediateDirectories: true)
    let sourceCode: String
    let fileName: String
    switch productType {
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

    self.createFile(
      atPath: sourcesDirURL.appendingPathComponent(fileName).path(),
      contents: Data(sourceCode.utf8)
    )
  }
  public func createFileStructure(
    forPackageType packageType: PackageType,
    forProductName productName: String,
    at pathURL: URL
  ) throws {
    guard packageType != .empty else {
      return
    }

    try self.createTargetSourceAt(pathURL, productName: productName, packageType)

    guard packageType == .library else {
      return
    }

    try createTestTargetAt(pathURL, productName)
  }
  private func createTestTargetAt(_ pathURL: URL, _ productName: String) throws {
    let testingDirURL = pathURL.appendingPathComponent("Tests/\(productName)Tests")
    try self.createDirectory(at: testingDirURL, withIntermediateDirectories: true)

    let testFileURL = testingDirURL.appendingPathComponent("\(productName)Tests.swift")
    let testCode = """
      import Testing
      @testable import \(productName)

      @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
      }
      """
    self.createFile(atPath: testFileURL.path(), contents: Data(testCode.utf8))
  }
  private func createTargetSourceAt(
    _ pathURL: URL, productName: String, _ packageType: PackageType
  ) throws {
    let productType: ProductType?

    switch packageType {
    case .empty:
      productType = nil
    case .library:
      productType = .library
    case .executable:
      productType = .executable
    }
    assert(productType != nil, "Unknown package type \(packageType)")
    guard let productType else {
      return
    }
    try self.createTargetSourceAt(pathURL, productName: productName, productType)
  }
}
