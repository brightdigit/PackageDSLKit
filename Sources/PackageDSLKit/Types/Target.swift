//
//  Target.swift
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

public import SwiftPackageManagerKit

/// Represents a Swift package target with its type name and dependencies.
///
/// A target is a fundamental building block of a Swift package that groups
/// source files together and defines their dependencies on other targets.
public struct Target: TypeSource, Sendable {
  /// The name of the target type.
  public let typeName: String

  /// An array of dependency references that this target depends on.
  public let dependencies: [DependencyRef]

  /// Creates a new target with the specified type name and dependencies.
  ///
  /// - Parameters:
  ///   - typeName: The name of the target type.
  ///   - dependencies: An array of dependency references. Defaults to an empty array.
  public init(typeName: String, dependencies: [DependencyRef] = []) {
    self.typeName = typeName
    self.dependencies = dependencies
  }
}

extension Target {
  /// Creates a Target from SwiftPackageManager target data.
  ///
  /// This initializer converts a SwiftPackageManagerKit.Target into a PackageDSLKit Target,
  /// but only for regular and executable targets. Test targets are excluded.
  ///
  /// - Parameter spmTarget: The SwiftPackageManagerKit target to convert.
  /// - Returns: A new Target instance, or nil if the target type is not supported.
  public init?(spmTarget: SwiftPackageManagerKit.Target) {
    // Only convert regular and executable targets, skip test targets
    guard spmTarget.type == .regular || spmTarget.type == .executable else {
      return nil
    }

    // Convert dependencies
    let dependencies: [DependencyRef] = spmTarget.dependencies.compactMap { dependency in
      switch dependency {
      case .byName(let name, _):
        return DependencyRef(name: name)
      case .product(let productName, _, _):
        return DependencyRef(name: productName)
      }
    }

    self.init(
      typeName: spmTarget.name,
      dependencies: dependencies
    )
  }
}
