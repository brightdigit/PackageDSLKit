//
//  PackageDSLManager.swift
//  PackageDSLKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// The main SDK entry point for package manipulation using PackageDSL
@MainActor
public final class PackageDSLManager: Sendable {
  
  // MARK: - Properties
  
  /// The URL of the package directory
  public let packageURL: URL
  
  /// The name of the package
  public private(set) var packageName: String
  
  /// Products in the package
  public private(set) var products: [Product]
  
  /// Targets in the package
  public private(set) var targets: [Target]
  
  /// Test targets in the package
  public private(set) var testTargets: [TestTarget]
  
  /// Package dependencies
  public private(set) var dependencies: [Dependency]
  
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

// MARK: - Package Type Creation

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
      let target = Target(typeName: packageName, dependencies: [])
      targets.append(target)
      
      if let product = Product(name: packageName, type: type) {
        products.append(product)
      }
      
    case .executable:
      let target = Target(typeName: packageName, dependencies: [])
      targets.append(target)
      
      if let product = Product(name: packageName, type: type) {
        products.append(product)
      }
      
    case .empty:
      // Empty package has no default targets or products
      break
    }
    
    return self
  }
}