//
//  TestTarget.swift
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

/// Represents a test target in a Swift package.
///
/// A test target contains unit tests or integration tests for the package,
/// and can depend on other targets or products.
public struct TestTarget: TypeSource, Sendable {
  /// The name of the test target type.
  public let typeName: String

  /// An array of dependency references that this test target depends on.
  public let dependencies: [DependencyRef]

  /// Creates a new test target with the specified type name and dependencies.
  ///
  /// - Parameters:
  ///   - typeName: The name of the test target type.
  ///   - dependencies: An array of dependency references. Defaults to an empty array.
  public init(typeName: String, dependencies: [DependencyRef] = []) {
    self.typeName = typeName
    self.dependencies = dependencies
  }
}

extension TestTarget {
  /// Creates a test target for the specified product.
  ///
  /// This convenience initializer creates a test target with a name derived
  /// from the product name by appending "Tests".
  ///
  /// - Parameter product: The product to create a test target for.
  public init(for product: Product) {
    self.init(typeName: product.typeName + "Tests")
  }
}

extension TestTarget {
  /// Creates a TestTarget from SwiftPackageManager target data.
  ///
  /// This initializer converts a SwiftPackageManagerKit.Target into a PackageDSLKit TestTarget,
  /// but only for test targets. Regular and executable targets are excluded.
  ///
  /// - Parameter spmTarget: The SwiftPackageManagerKit target to convert.
  /// - Returns: A new TestTarget instance, or nil if the target type is not a test target.
  public init?(spmTarget: SwiftPackageManagerKit.Target) {
    // Only convert test targets
    guard spmTarget.type == .test else {
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
