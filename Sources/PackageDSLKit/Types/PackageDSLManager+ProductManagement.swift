//
//  PackageDSLManager+ProductManagement.swift
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

// MARK: - Product Management

extension PackageDSLManager {
  /// Add a product to the package
  /// - Parameters:
  ///   - name: The product name
  ///   - type: The product type (.library or .executable)
  ///   - targets: Target names that make up this product
  /// - Returns: Self for method chaining
  /// - Throws: PackageError if product name already exists or targets don't exist
  @discardableResult
  public func addProduct(name: String, type: ProductType, targets: [String]) throws
    -> PackageDSLManager
  {
    // Check for duplicate product names
    guard !products.contains(where: { $0.typeName == name }) else {
      throw PackageError.duplicateProductName(name)
    }

    // Verify all target names exist
    let allTargetNames = self.targets.map(\.typeName) + testTargets.map(\.typeName)
    for targetName in targets {
      guard allTargetNames.contains(targetName) else {
        throw PackageError.targetNotFound(targetName)
      }
    }

    // Create dependency references for the targets
    let targetDependencies = targets.map { DependencyRef(name: $0) }

    let product = Product(
      typeName: name,
      name: name,
      dependencies: targetDependencies,
      productType: type
    )

    products.append(product)
    return self
  }

  /// Remove a product from the package
  /// - Parameter name: The product name to remove
  /// - Returns: Self for method chaining
  /// - Throws: PackageError.productNotFound if product doesn't exist
  @discardableResult
  public func removeProduct(name: String) throws -> PackageDSLManager {
    // Check if product exists
    guard products.contains(where: { $0.typeName == name }) else {
      throw PackageError.productNotFound(name)
    }

    // Remove the product
    products.removeAll { $0.typeName == name }
    return self
  }
}
