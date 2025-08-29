//
//  FileManager+Helpers.swift
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

import Foundation

// MARK: - Internal Helper Methods
extension FileManager {
  /// Reads directory contents recursively, filtering by file extension
  ///
  /// - Parameters:
  ///   - path: The directory path to read
  ///   - fileExtension: The file extension to filter by (default: "swift")
  /// - Returns: Array of file contents as strings
  /// - Throws: File system errors
  internal func readDirectoryContents(at path: String, fileExtension: String = "swift") throws
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

  /// Creates a test target at the specified path for a product
  ///
  /// - Parameters:
  ///   - pathURL: The base path URL where the test target should be created
  ///   - productName: The name of the product to create tests for
  /// - Throws: An error if directory or file creation fails
  internal func createTestTargetAt(_ pathURL: URL, _ productName: String) throws {
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
    self.createFile(atPath: testFileURL.polyfill().path(), contents: Data(testCode.utf8))
  }

  /// Creates target source files at the specified path for a package type
  ///
  /// - Parameters:
  ///   - pathURL: The base path URL where source files should be created
  ///   - productName: The name of the product
  ///   - packageType: The type of package
  /// - Throws: An error if directory or file creation fails
  internal func createTargetSourceAt(
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
