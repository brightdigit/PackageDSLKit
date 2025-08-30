//
//  PackageDirectoryConfiguration.swift
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

import SwiftPackageManagerKit

/// Configuration for a package directory structure containing all package components
///
/// This struct represents the complete configuration of a Swift package directory,
/// including products, dependencies, targets, test targets, and supported platforms.
/// It serves as the central configuration object for package generation and validation.
public struct PackageDirectoryConfiguration: Sendable, Hashable, Codable {
  /// The index containing references to all package components
  public let index: Index
  /// Array of products defined in the package
  public let products: [Product]
  /// Array of dependencies required by the package
  public let dependencies: [Dependency]
  /// Array of targets that make up the package
  public let targets: [Target]
  /// Array of test targets for the package
  public let testTargets: [TestTarget]
  /// Array of supported platform configurations
  public let supportedPlatformSets: [SupportedPlatformSet]

  /// Creates a new package directory configuration
  ///
  /// - Parameters:
  ///   - index: The index containing component references
  ///   - products: Products to include (default: empty array)
  ///   - dependencies: Dependencies to include (default: empty array)
  ///   - targets: Targets to include (default: empty array)
  ///   - testTargets: Test targets to include (default: empty array)
  ///   - supportedPlatformSets: Platform configurations to include (default: empty array)
  public init(
    index: Index,
    products: [Product] = [],
    dependencies: [Dependency] = [],
    targets: [Target] = [],
    testTargets: [TestTarget] = [],
    supportedPlatformSets: [SupportedPlatformSet] = []
  ) {
    self.index = index
    self.products = products
    self.dependencies = dependencies
    self.targets = targets
    self.testTargets = testTargets
    self.supportedPlatformSets = supportedPlatformSets
  }
}

extension PackageDirectoryConfiguration {
  // SPM-based initializer - converts PackageInfo to PackageDirectoryConfiguration
  internal init(from packageInfo: PackageInfo) throws(PackageDSLError) {
    // Convert SPM products to PackageDSLKit products
    let products = packageInfo.products.compactMap { Product(spmProduct: $0) }

    // Convert SPM targets to PackageDSLKit targets (excluding test targets)
    let targets = packageInfo.targets.compactMap { Target(spmTarget: $0) }

    // Convert SPM targets to PackageDSLKit test targets (only test targets)
    let testTargets = packageInfo.targets.compactMap { TestTarget(spmTarget: $0) }

    // Convert SPM dependencies to PackageDSLKit dependencies
    let dependencies = packageInfo.dependencies.compactMap { spmDependency -> Dependency? in
      switch spmDependency {
      case .sourceControl(let sourceControlDep):
        return Dependency(
          typeName: sourceControlDep.identity,
          type: .package,
          dependency: sourceControlDep.identity,
          package: DependencyRef(name: sourceControlDep.identity)
        )
      case .fileSystem(let fileSystemDep):
        return Dependency(
          typeName: fileSystemDep.identity,
          type: .package,
          dependency: fileSystemDep.identity,
          package: DependencyRef(name: fileSystemDep.identity)
        )
      }
    }

    // Convert SPM platforms to PackageDSLKit supported platform sets
    let supportedPlatformSets = packageInfo.platforms.compactMap {
      platform -> SupportedPlatformSet? in
      // Create a single platform set for all platforms
      guard let platformSet = SupportedPlatformSet(spmPlatforms: [platform]) else {
        return nil
      }
      return platformSet
    }

    // Create index from the converted components
    let entries = products.map { EntryRef(name: $0.typeName) }
    let dependencyRefs = dependencies.map { DependencyRef(name: $0.typeName) }
    let testTargetRefs = testTargets.map { TestTargetRef(name: $0.typeName) }

    // Create swift settings from tools version
    let swiftSettings: [SwiftSettingRef] = []

    // Create modifiers (empty for now, can be extended later)
    let modifiers: [Modifier] = []

    let index = Index(
      entries: entries,
      dependencies: dependencyRefs,
      testTargets: testTargetRefs,
      swiftSettings: swiftSettings,
      modifiers: modifiers
    )

    self.init(
      index: index,
      products: products,
      dependencies: dependencies,
      targets: targets,
      testTargets: testTargets,
      supportedPlatformSets: supportedPlatformSets
    )
  }

  internal func createComponents() -> [Component] {
    var components: [Component] = []
    components.append(contentsOf: products.map { $0.createComponent() })
    components.append(contentsOf: dependencies.map { $0.createComponent() })
    components.append(contentsOf: targets.map { $0.createComponent() })
    components.append(contentsOf: testTargets.map { $0.createComponent() })
    components.append(contentsOf: supportedPlatformSets.map { $0.createComponent() })
    return components
  }
}
