//
//  PackageDSLManager+FluentAPI.swift
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

internal import Foundation

// MARK: - Fluent API Extensions

extension PackageDSLManager {
  /// Fluent API method to add multiple dependencies at once
  /// - Parameter dependencies: Array of (url, requirement) tuples
  /// - Returns: Self for method chaining
  @discardableResult
  public func addDependencies(_ dependencies: [(url: String, requirement: VersionRequirement)])
    throws -> PackageDSLManager
  {
    for (url, requirement) in dependencies {
      try addDependency(url: url, requirement: requirement)
    }
    return self
  }

  /// Fluent API method to add multiple path dependencies at once
  /// - Parameter paths: Array of local paths
  /// - Returns: Self for method chaining
  @discardableResult
  public func addPathDependencies(_ paths: [String]) throws -> PackageDSLManager {
    for path in paths {
      try addDependency(path: path)
    }
    return self
  }

  /// Convenience method to add dependency with string version requirement
  /// - Parameters:
  ///   - url: The URL of the package repository
  ///   - versionString: String representation of version requirement
  /// - Returns: Self for method chaining
  /// - Throws: PackageError if dependency already exists or version string is invalid
  @discardableResult
  public func addDependency(url: String, version versionString: String) throws -> PackageDSLManager
  {
    guard let requirement = VersionRequirement.parse(versionString) else {
      throw PackageError.invalidConfiguration("Invalid version requirement: \(versionString)")
    }
    return try addDependency(url: url, requirement: requirement)
  }

  /// Convenience method to add registry dependency with string version requirement
  /// - Parameters:
  ///   - identity: The package identity in the registry
  ///   - versionString: String representation of version requirement
  /// - Returns: Self for method chaining
  /// - Throws: PackageError if dependency already exists or version string is invalid
  @discardableResult
  public func addDependency(identity: String, version versionString: String) throws
    -> PackageDSLManager
  {
    guard let requirement = VersionRequirement.parse(versionString) else {
      throw PackageError.invalidConfiguration("Invalid version requirement: \(versionString)")
    }
    return try addDependency(identity: identity, requirement: requirement)
  }
}
