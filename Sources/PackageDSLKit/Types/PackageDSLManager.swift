//
//  PackageDSLManager.swift
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

/// The main SDK entry point for package manipulation using PackageDSL
@MainActor
public final class PackageDSLManager {
  // MARK: - Properties

  /// The URL of the package directory
  public let packageURL: URL

  /// The name of the package
  public private(set) var packageName: String

  /// Products in the package
  public fileprivate(set) var products: [Product]

  /// Targets in the package
  public fileprivate(set) var targets: [Target]

  /// Test targets in the package
  public fileprivate(set) var testTargets: [TestTarget]

  /// Package dependencies
  public fileprivate(set) var dependencies: [Dependency]

  /// Supported platform sets
  public private(set) var supportedPlatformSets: [SupportedPlatformSet]

  /// Swift settings
  public private(set) var swiftSettings: [SwiftSettingRef]

  /// Package modifiers
  public private(set) var modifiers: [Modifier]

  // MARK: - Initialization

  /// Initialize PackageDSLManager with a package URL
  /// - Parameter packageURL: The URL to the package directory
  public init(packageURL: URL) {
    self.packageURL = packageURL
    self.packageName = packageURL.lastPathComponent
    self.products = []
    self.targets = []
    self.testTargets = []
    self.dependencies = []
    self.supportedPlatformSets = []
    self.swiftSettings = []
    self.modifiers = []
  }

  /// Initialize PackageDSLManager with a package URL and name
  /// - Parameters:
  ///   - packageURL: The URL to the package directory
  ///   - packageName: The custom name for the package
  public init(packageURL: URL, packageName: String) {
    self.packageURL = packageURL
    self.packageName = packageName
    self.products = []
    self.targets = []
    self.testTargets = []
    self.dependencies = []
    self.supportedPlatformSets = []
    self.swiftSettings = []
    self.modifiers = []
  }

  // MARK: - Package Configuration

  /// Set the package name
  /// - Parameter name: The new package name
  /// - Returns: Self for method chaining
  @discardableResult
  public func setPackageName(_ name: String) -> PackageDSLManager {
    self.packageName = name
    return self
  }

  // MARK: - Internal Specifications

  /// Get the current package specifications
  internal var specifications: PackageSpecifications {
    PackageSpecifications(
      products: products,
      dependencies: dependencies,
      targets: targets,
      testTargets: testTargets,
      supportedPlatformSets: supportedPlatformSets,
      swiftSettings: swiftSettings,
      modifiers: modifiers
    )
  }
}

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
// MARK: - Dependency Management

extension PackageDSLManager {
  /// Add a URL-based package dependency
  /// - Parameters:
  ///   - url: The URL of the package repository
  ///   - requirement: Version requirement for the dependency
  /// - Returns: Self for method chaining
  /// - Throws: PackageError if dependency already exists
  @discardableResult
  public func addDependency(url: String, requirement: VersionRequirement) throws
    -> PackageDSLManager
  {
    let name = extractPackageName(from: url)

    // Check for duplicate dependency names
    guard !dependencies.contains(where: { $0.typeName == name }) else {
      throw PackageError.duplicateDependencyName(name)
    }

    let dependency = Dependency(
      typeName: name,
      type: .package,
      dependency: "\".package(url: \"\(url)\", \(requirement.asSPMString()))\"",
      package: DependencyRef(name: name)
    )

    dependencies.append(dependency)
    return self
  }

  /// Add a local path-based package dependency
  /// - Parameter path: The local file system path to the package
  /// - Returns: Self for method chaining
  /// - Throws: PackageError if dependency already exists
  @discardableResult
  public func addDependency(path: String) throws -> PackageDSLManager {
    let name = URL(fileURLWithPath: path).lastPathComponent

    // Check for duplicate dependency names
    guard !dependencies.contains(where: { $0.typeName == name }) else {
      throw PackageError.duplicateDependencyName(name)
    }

    let dependency = Dependency(
      typeName: name,
      type: .package,
      dependency: "\".package(path: \"\(path)\")\"",
      package: DependencyRef(name: name)
    )

    dependencies.append(dependency)
    return self
  }

  /// Add a registry-based package dependency
  /// - Parameters:
  ///   - identity: The package identity in the registry
  ///   - requirement: Version requirement for the dependency
  /// - Returns: Self for method chaining
  /// - Throws: PackageError if dependency already exists
  @discardableResult
  public func addDependency(identity: String, requirement: VersionRequirement) throws
    -> PackageDSLManager
  {
    // Check for duplicate dependency names
    guard !dependencies.contains(where: { $0.typeName == identity }) else {
      throw PackageError.duplicateDependencyName(identity)
    }

    let dependency = Dependency(
      typeName: identity,
      type: .package,
      dependency: "\".package(id: \"\(identity)\", \(requirement.asSPMString()))\"",
      package: DependencyRef(name: identity)
    )

    dependencies.append(dependency)
    return self
  }

  /// Remove a package dependency
  /// - Parameters:
  ///   - name: The dependency name to remove
  ///   - force: If true, remove even if targets depend on it
  /// - Returns: Self for method chaining
  /// - Throws: PackageError.dependencyNotFound if dependency doesn't exist, or cascadeRemovalRequired if targets depend on it and force is false
  @discardableResult
  public func removeDependency(name: String, force: Bool = false) throws -> PackageDSLManager {
    // Check if dependency exists
    guard dependencies.contains(where: { $0.typeName == name }) else {
      throw PackageError.dependencyNotFound(name)
    }

    let dependentTargets = findDependencyDependentTargets(name)
    try validateDependencyRemoval(name: name, dependents: dependentTargets, force: force)

    removeDependencyFromCollection(name)
    cleanupDependencyReferences(name)

    return self
  }

  private func findDependencyDependentTargets(_ name: String) -> [String] {
    let dependentRegularTargets = targets.filter { target in
      target.dependencies.contains { $0.name == name }
    }
    let dependentTestTargets = testTargets.filter { testTarget in
      testTarget.dependencies.contains { $0.name == name }
    }

    return dependentRegularTargets.map(\.typeName) + dependentTestTargets.map(\.typeName)
  }

  private func validateDependencyRemoval(name: String, dependents: [String], force: Bool) throws {
    if !dependents.isEmpty && !force {
      throw PackageError.cascadeRemovalRequired(name, dependents)
    }
  }

  private func removeDependencyFromCollection(_ name: String) {
    dependencies.removeAll { $0.typeName == name }
  }

  private func cleanupDependencyReferences(_ name: String) {
    // Remove dependency references from targets (always clean up references)
    targets = targets.map { target in
      let filteredDependencies = target.dependencies.filter { $0.name != name }
      return Target(
        typeName: target.typeName,
        dependencies: filteredDependencies
      )
    }

    // Remove dependency references from test targets
    testTargets = testTargets.map { testTarget in
      let filteredDependencies = testTarget.dependencies.filter { $0.name != name }
      return TestTarget(
        typeName: testTarget.typeName,
        dependencies: filteredDependencies
      )
    }
  }

  /// Helper method to extract package name from URL
  private func extractPackageName(from url: String) -> String {
    guard let urlObject = URL(string: url) else {
      return url.components(separatedBy: "/").last ?? url
    }

    let pathComponent = urlObject.lastPathComponent

    // Remove .git suffix if present
    if pathComponent.hasSuffix(".git") {
      return String(pathComponent.dropLast(4))
    }

    return pathComponent
  }
}

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
