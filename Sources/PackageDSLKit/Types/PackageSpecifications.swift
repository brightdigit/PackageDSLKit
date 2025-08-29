//
//  PackageSpecifications.swift
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

/// Represents the complete specifications for a Swift package.
///
/// This structure contains all the components that define a Swift package,
/// including products, dependencies, targets, and platform requirements.
public struct PackageSpecifications: Sendable, Hashable, Codable {
  /// The products defined in the package.
  public let products: [Product]

  /// The dependencies required by the package.
  public let dependencies: [Dependency]

  /// The targets defined in the package.
  public let targets: [Target]

  /// The test targets defined in the package.
  public let testTargets: [TestTarget]

  /// The supported platform sets for the package.
  public let supportedPlatformSets: [SupportedPlatformSet]

  /// The Swift settings applied to the package.
  public let swiftSettings: [SwiftSettingRef]

  /// The modifiers applied to the package.
  public let modifiers: [Modifier]

  /// Creates a new package specifications instance with the given components.
  ///
  /// - Parameters:
  ///   - products: The products defined in the package. Defaults to an empty array.
  ///   - dependencies: The dependencies required by the package. Defaults to an empty array.
  ///   - targets: The targets defined in the package. Defaults to an empty array.
  ///   - testTargets: The test targets defined in the package. Defaults to an empty array.
  ///   - supportedPlatformSets: The supported platform sets for the package. Defaults to an empty array.
  ///   - swiftSettings: The Swift settings applied to the package. Defaults to an empty array.
  ///   - modifiers: The modifiers applied to the package. Defaults to an empty array.
  public init(
    products: [Product] = [],
    dependencies: [Dependency] = [],
    targets: [Target] = [],
    testTargets: [TestTarget] = [],
    supportedPlatformSets: [SupportedPlatformSet] = [],
    swiftSettings: [SwiftSettingRef] = [],
    modifiers: [Modifier] = []
  ) {
    self.products = products
    self.dependencies = dependencies
    self.targets = targets
    self.testTargets = testTargets
    self.supportedPlatformSets = supportedPlatformSets
    self.swiftSettings = swiftSettings
    self.modifiers = modifiers
  }
}

extension PackageSpecifications {
  /// Creates package specifications from a package directory configuration.
  ///
  /// This initializer extracts the necessary components from a directory configuration
  /// to create a complete package specification.
  ///
  /// - Parameter directoryConfiguration: The directory configuration to convert.
  /// - Throws: A PackageDSLError if the conversion fails.
  public init(from directoryConfiguration: PackageDirectoryConfiguration) throws(PackageDSLError) {
    self.products = directoryConfiguration.products
    self.dependencies = directoryConfiguration.dependencies
    self.targets = directoryConfiguration.targets
    self.testTargets = directoryConfiguration.testTargets
    self.swiftSettings = directoryConfiguration.index.swiftSettings
    self.supportedPlatformSets = directoryConfiguration.supportedPlatformSets
    self.modifiers = directoryConfiguration.index.modifiers
  }
}

extension PackageSpecifications {
  /// Updates the package specifications using a property descriptor and transform function.
  ///
  /// This method provides a type-safe way to update specific components of the package
  /// specifications using a descriptor type and transformation function.
  ///
  /// - Parameters:
  ///   - descriptor: The property descriptor type to use for the update.
  ///   - transform: A function that transforms the array of properties.
  /// - Returns: A new PackageSpecifications instance with the transformed properties.
  public func updating<P: PackagePropertyDescriptor>(descriptor: P.Type, transform: ([P]) -> [P])
    -> PackageSpecifications
  {
    descriptor.update(original: self, transform: transform)
  }
}
