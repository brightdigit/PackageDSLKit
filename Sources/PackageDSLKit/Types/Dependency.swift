//
//  Dependency.swift
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

/// A dependency relationship between package components
///
/// This struct represents a dependency that one component has on another,
/// including the type of dependency and optional package references.
public struct Dependency: TypeSource, Sendable {
  /// The name of the dependency type
  public let typeName: String

  /// The type of dependency relationship
  public let type: DependencyType
  /// The name of the specific dependency, if applicable
  public let dependency: String?
  /// Reference to the package containing the dependency, if applicable
  public let package: DependencyRef?

  /// Creates a new dependency
  ///
  /// - Parameters:
  ///   - typeName: The name of the dependency type
  ///   - type: The type of dependency relationship
  ///   - dependency: The name of the specific dependency (default: nil)
  ///   - package: Reference to the package containing the dependency (default: nil)
  public init(
    typeName: String,
    type: DependencyType,
    dependency: String? = nil,
    package: DependencyRef? = nil
  ) {
    self.typeName = typeName
    self.type = type
    self.dependency = dependency
    self.package = package
  }
}
