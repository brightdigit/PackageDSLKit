//
//  PackageFilesInterface.swift
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

/// A protocol defining the interface for managing Swift package files and directories.
///
/// This protocol provides methods for creating, reading, and managing files and directories
/// within a Swift package structure, including Package.swift files and source code directories.
public protocol PackageFilesInterface {
  /// The URL of the current working directory.
  var currentDirectoryURL: URL { get }

  /// Creates a directory at the specified URL.
  ///
  /// - Parameters:
  ///   - url: The URL where the directory should be created.
  ///   - createIntermediates: Whether to create intermediate directories if they don't exist.
  /// - Throws: An error if the directory cannot be created.
  func createDirectory(
    at url: URL,
    withIntermediateDirectories createIntermediates: Bool
  ) throws

  /// Creates a file at the specified URL with the given text content.
  ///
  /// - Parameters:
  ///   - url: The URL where the file should be created.
  ///   - text: The text content to write to the file.
  func createFile(at url: URL, text: String)

  /// Extracts the Swift version from a package directory.
  ///
  /// - Parameter directoryURL: The URL of the directory containing the Package.swift file.
  /// - Returns: The Swift version found in the package, or nil if not found.
  func swiftVersion(from directoryURL: URL) -> SwiftVersion?

  /// Writes a Package.swift file with the specified Swift version and DSL sources.
  ///
  /// - Parameters:
  ///   - swiftVersion: The Swift version to use in the package file.
  ///   - dslSourcesURL: The URL of the DSL sources directory.
  ///   - pathURL: The URL where the Package.swift file should be written.
  /// - Throws: An error if the file cannot be written.
  func writePackageSwiftFile(
    swiftVersion: SwiftVersion,
    from dslSourcesURL: URL,
    to pathURL: URL
  ) throws

  /// Creates the file structure for a package of the specified type.
  ///
  /// - Parameters:
  ///   - packageType: The type of package to create the structure for.
  ///   - productName: The name of the product.
  ///   - pathURL: The URL where the file structure should be created.
  /// - Throws: An error if the file structure cannot be created.
  func createFileStructure(
    forPackageType packageType: PackageType,
    forProductName productName: String,
    at pathURL: URL
  ) throws

  /// Creates target source files at the specified location.
  ///
  /// - Parameters:
  ///   - pathURL: The URL where the target source should be created.
  ///   - productName: The name of the product.
  ///   - productType: The type of product to create sources for.
  /// - Throws: An error if the target source cannot be created.
  func createTargetSourceAt(
    _ pathURL: URL, productName: String, _ productType: ProductType
  ) throws
}
