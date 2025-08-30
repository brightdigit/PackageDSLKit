//
//  PackageDSLManager+TargetManagement.swift
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

// MARK: - Package Type Creation & Target Management

extension PackageDSLManager {
  /// Create a package with the specified type
  /// - Parameters:
  ///   - name: The package name (optional, uses current packageName if nil)
  ///   - type: The package type (.library, .executable, or .empty)
  /// - Returns: Self for method chaining
  @discardableResult
  public func createPackage(name: String? = nil, type: PackageType) -> PackageDSLManager {
    if let name = name {
      self.packageName = name
    }

    // Create default target and product for non-empty packages
    switch type {
    case .library:
      self.createDefaultTarget(.library)

    case .executable:
      self.createDefaultTarget(.executable)

    case .empty:
      // Empty package has no default targets or products
      break
    }

    return self
  }

  private func createDefaultTarget(_ targetType: TargetType) {
    do {
      try addTarget(name: packageName, type: targetType)
      let productType: ProductType = targetType == .executable ? .executable : .library
      try addProduct(name: packageName, type: productType, targets: [packageName])
    } catch {
      // This should not happen in normal usage as we're creating a new package
      assertionFailure("Failed to create default target and product: \(error)")
    }
  }

  /// Add a target to the package
  /// - Parameters:
  ///   - name: The target name
  ///   - type: The target type (.library, .executable, or .test)
  ///   - dependencies: Target dependencies
  /// - Returns: Self for method chaining
  /// - Throws: PackageError if target name already exists
  @discardableResult
  public func addTarget(name: String, type: TargetType, dependencies: [DependencyRef] = []) throws
    -> PackageDSLManager
  {
    // Check for duplicate target names
    let existingNames = targets.map(\.typeName) + testTargets.map(\.typeName)
    guard !existingNames.contains(name) else {
      throw PackageError.duplicateTargetName(name)
    }

    switch type {
    case .library, .executable:
      let target = Target(typeName: name, dependencies: dependencies)
      targets.append(target)

    case .test:
      let testTarget = TestTarget(typeName: name, dependencies: dependencies)
      testTargets.append(testTarget)
    }

    return self
  }

  /// Remove a target from the package
  /// - Parameters:
  ///   - name: The target name to remove
  ///   - force: If true, remove even if cascade removal is required
  /// - Returns: Self for method chaining
  /// - Throws: PackageError.cascadeRemovalRequired if target is used by products and force is false
  @discardableResult
  public func removeTarget(name: String, force: Bool = false) throws -> PackageDSLManager {
    try validateTargetExists(name)

    let dependents = findTargetDependents(name)
    try validateRemoval(targetName: name, dependents: dependents, force: force)

    removeTargetFromCollections(name)

    if force {
      cleanupTargetReferences(name)
    }

    return self
  }

  private func validateTargetExists(_ name: String) throws {
    let existingTargetNames = targets.map(\.typeName) + testTargets.map(\.typeName)
    guard existingTargetNames.contains(name) else {
      throw PackageError.targetNotFound(name)
    }
  }

  private func findTargetDependents(_ name: String) -> [String] {
    let dependentProducts = products.filter { product in
      product.dependencies.contains { $0.name == name }
    }

    let dependentRegularTargets = targets.filter { target in
      target.dependencies.contains { $0.name == name }
    }

    let dependentTestTargets = testTargets.filter { testTarget in
      testTarget.dependencies.contains { $0.name == name }
    }

    return dependentProducts.map(\.typeName) + dependentRegularTargets.map(\.typeName)
      + dependentTestTargets.map(\.typeName)
  }

  private func validateRemoval(targetName: String, dependents: [String], force: Bool) throws {
    if !dependents.isEmpty && !force {
      throw PackageError.cascadeRemovalRequired(targetName, dependents)
    }
  }

  private func removeTargetFromCollections(_ name: String) {
    targets.removeAll { $0.typeName == name }
    testTargets.removeAll { $0.typeName == name }
  }

  private func cleanupTargetReferences(_ name: String) {
    // Remove products that reference this target
    products.removeAll { product in
      product.dependencies.contains { $0.name == name }
    }

    // Remove target dependencies from other targets
    targets = targets.map { target in
      let filteredDependencies = target.dependencies.filter { $0.name != name }
      return Target(typeName: target.typeName, dependencies: filteredDependencies)
    }

    testTargets = testTargets.map { testTarget in
      let filteredDependencies = testTarget.dependencies.filter { $0.name != name }
      return TestTarget(typeName: testTarget.typeName, dependencies: filteredDependencies)
    }
  }
}
