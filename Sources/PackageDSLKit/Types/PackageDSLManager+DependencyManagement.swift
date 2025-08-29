//
//  PackageDSLManager+DependencyManagement.swift
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
