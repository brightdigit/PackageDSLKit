//
//  PackageParser.swift
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
public import SwiftPackageManagerKit

/// A parser that reads package specifications from directory structures
///
/// This struct parses Swift package directories to extract package specifications,
/// using Swift Package Manager's JSON output for reliable parsing.
public struct PackageParser: Sendable, Hashable, Codable {
  /// Creates a new package parser
  public init() {
  }
  #if canImport(Foundation) && (os(macOS) || os(Linux))
    /// Parses a package directory using the default Swift executor
    ///
    /// - Parameter directoryURL: The URL of the package directory to parse
    ///
    /// - Returns: Package specifications extracted from the directory
    /// - Throws: `PackageDSLError` if parsing fails
    public func parse(at directoryURL: URL)
      async throws(PackageDSLError)
      -> PackageSpecifications
    {
      try await self.parse(at: directoryURL, swiftExecutor: ProcessRunner.swift)
    }
  #endif
  /// Parses a package directory using a custom Swift executor
  ///
  /// - Parameters:
  ///   - directoryURL: The URL of the package directory to parse
  ///   - swiftExecutor: A custom Swift command executor function
  ///
  /// - Returns: Package specifications extracted from the directory
  /// - Throws: `PackageDSLError` if parsing fails
  public func parse(
    at directoryURL: URL,
    swiftExecutor: @escaping Executor.SwiftCommandExecutor
  )
    async throws(PackageDSLError)
    -> PackageSpecifications
  {
    // Use SPM JSON parsing instead of SwiftSyntax parsing
    let executor: Executor
    do {
      executor = try Executor(packageDirectory: directoryURL, swiftExecutor: swiftExecutor)
    } catch {
      throw .other(error)
    }

    let packageInfo: PackageInfo
    do {
      packageInfo = try await executor.dumpPackage()
    } catch {
      throw .other(error)
    }

    let directoryConfiguration = try PackageDirectoryConfiguration(from: packageInfo)

    return try .init(from: directoryConfiguration)
  }
}
