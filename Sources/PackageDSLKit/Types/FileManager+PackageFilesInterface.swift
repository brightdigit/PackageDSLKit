//
//  FileManager+PackageFilesInterface.swift
//  MistKit
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

public import Foundation

// MARK: - PackageFilesInterface Implementation
extension FileManager: PackageFilesInterface {
  /// The current working directory as a URL
  public var currentDirectoryURL: URL {
    URL(fileURLWithPath: currentDirectoryPath)
  }

  /// Writes a Package.swift file with the specified Swift version and DSL sources
  ///
  /// - Parameters:
  ///   - swiftVersion: The Swift tools version to use
  ///   - dslSourcesURL: The URL containing DSL source files
  ///   - pathURL: The destination URL where the Package.swift file will be created
  ///
  /// - Throws: An error if reading the directory contents fails
  public func writePackageSwiftFile(
    swiftVersion: SwiftVersion,
    from dslSourcesURL: URL,
    to pathURL: URL
  ) throws {
    let contents = try self.readDirectoryContents(
      at: dslSourcesURL.polyfill().path(),
      fileExtension: "swift"
    )

    let packageFileURL = pathURL.appendingPathComponent("Package.swift")
    let strings =
      [
        "// swift-tools-version: \(swiftVersion)",
        SupportCodeBlock.syntaxNode.trimmedDescription,
      ] + contents
    let data = Data(strings.joined(separator: "\n").utf8)
    self.createFile(atPath: packageFileURL.polyfill().path(), contents: data)
    // TODO: log error if file creation fails
  }

  /// Creates a directory at the specified URL
  ///
  /// - Parameters:
  ///   - url: The URL where the directory should be created
  ///   - createIntermediates: Whether to create intermediate directories if they don't exist
  ///
  /// - Throws: An error if directory creation fails
  public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool)
    throws
  {
    try self.createDirectory(
      at: url,
      withIntermediateDirectories: createIntermediates,
      attributes: nil
    )
  }

  /// Creates a file at the specified URL with the given text content
  ///
  /// - Parameters:
  ///   - url: The URL where the file should be created
  ///   - text: The text content to write to the file
  public func createFile(at url: URL, text: String) {
    self.createFile(atPath: url.polyfill().path(), contents: Data(text.utf8))
  }

  /// Reads the Swift version from a directory, checking both .swift-version file and Package.swift
  ///
  /// - Parameter directoryURL: The directory URL to check for Swift version information
  ///
  /// - Returns: The Swift version if found, nil otherwise
  public func swiftVersion(from directoryURL: URL) -> SwiftVersion? {
    let swiftVersionURL = directoryURL.polyfill().appending(component: ".swift-version")
    let packageSwiftURL = directoryURL.polyfill().appending(component: "Package.swift")

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

  /// Creates target source files at the specified path for a product
  ///
  /// - Parameters:
  ///   - pathURL: The base path URL where source files should be created
  ///   - productName: The name of the product
  ///   - productType: The type of product (library, executable, etc.)
  ///
  /// - Throws: An error if directory or file creation fails
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
      atPath: sourcesDirURL.appendingPathComponent(fileName).polyfill().path(),
      contents: Data(sourceCode.utf8)
    )
  }

  /// Creates the complete file structure for a package at the specified path
  ///
  /// - Parameters:
  ///   - packageType: The type of package to create
  ///   - productName: The name of the product
  ///   - pathURL: The base path URL where the file structure should be created
  ///
  /// - Throws: An error if directory or file creation fails
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
}
