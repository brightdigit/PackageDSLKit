//
//  SourceControlDependency.swift
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

/// Represents a source control dependency
///
/// This struct defines a dependency that is managed through source control systems
/// like Git, including information about the dependency's identity, location,
/// product filtering, version requirements, and associated traits.
public struct SourceControlDependency: Codable, Hashable, Sendable {
  /// The unique identity of this source control dependency.
  public let identity: String
  /// The location where this dependency can be found (e.g., remote URL, local path).
  public let location: DependencyLocation
  /// Optional filter to limit which products from this dependency are used.
  public let productFilter: String?
  /// The version requirement that must be satisfied by this dependency.
  public let requirement: VersionRequirement
  /// Additional traits or characteristics associated with this dependency.
  public let traits: [DependencyTrait]

  /// Creates a new SourceControlDependency instance with the specified configuration.
  ///
  /// - Parameters:
  ///   - identity: The unique identity of this dependency.
  ///   - location: The location where this dependency can be found.
  ///   - productFilter: Optional filter to limit which products are used (default: nil).
  ///   - requirement: The version requirement that must be satisfied.
  ///   - traits: Additional traits associated with this dependency (default: empty array).
  public init(
    identity: String,
    location: DependencyLocation,
    productFilter: String? = nil,
    requirement: VersionRequirement,
    traits: [DependencyTrait] = []
  ) {
    self.identity = identity
    self.location = location
    self.productFilter = productFilter
    self.requirement = requirement
    self.traits = traits
  }
}
