//
//  Product.swift
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

/// Represents a product in a Swift package.
///
/// A product defines a publicly available target that can be used by clients
/// of the package, such as a library or executable.
public struct Product: TypeSource, Sendable {
  /// The name of the product type.
  public let typeName: String

  /// The optional name of the product, if different from the type name.
  public let name: String?

  /// An array of dependency references that this product depends on.
  public let dependencies: [DependencyRef]

  /// The type of product (library or executable).
  public let productType: ProductType?

  /// Creates a new product with the specified configuration.
  ///
  /// - Parameters:
  ///   - typeName: The name of the product type.
  ///   - name: The optional name of the product. Defaults to nil.
  ///   - dependencies: An array of dependency references. Defaults to an empty array.
  ///   - productType: The type of product. Defaults to nil.
  public init(
    typeName: String,
    name: String? = nil,
    dependencies: [DependencyRef] = [],
    productType: ProductType? = nil
  ) {
    self.typeName = typeName
    self.name = name
    self.dependencies = dependencies
    self.productType = productType
  }
}

extension Product {
  /// Creates a product from a package type.
  ///
  /// This convenience initializer creates a product with the given name and
  /// infers the product type from the package type.
  ///
  /// - Parameters:
  ///   - name: The name of the product.
  ///   - type: The package type to infer the product type from.
  /// - Returns: A new Product instance, or nil if the package type cannot be converted.
  public init?(name: String, type: PackageType) {
    guard let productType = ProductType(type: type) else {
      return nil
    }
    self.init(typeName: name, productType: productType)
  }
}

extension Product {
  /// Creates a Product from SwiftPackageManager product data.
  ///
  /// This initializer converts a SwiftPackageManagerKit.Product into a PackageDSLKit Product.
  /// Plugin products are currently not supported and will return nil.
  ///
  /// - Parameter spmProduct: The SwiftPackageManagerKit product to convert.
  /// - Returns: A new Product instance, or nil if the product type is not supported.
  public init?(spmProduct: SwiftPackageManagerKit.Product) {
    // Convert SPMProductType to ProductType
    let productType: ProductType
    switch spmProduct.type {
    case .library(.static):
      productType = .library
    case .library(.dynamic):
      productType = .library
    case .library(.automatic):
      productType = .library
    case .executable:
      productType = .executable
    case .plugin:
      return nil  // Skip plugin products for now
    }

    // Convert targets to dependencies (simplified mapping)
    let dependencies = spmProduct.targets.map { DependencyRef(name: $0) }

    self.init(
      typeName: spmProduct.name,
      name: spmProduct.name,
      dependencies: dependencies,
      productType: productType
    )
  }
}

extension Product: PackagePropertyDescriptor {
  /// Retrieves the products from package specifications.
  ///
  /// - Parameter specifications: The package specifications to retrieve products from.
  /// - Returns: An array of products from the specifications.
  public static func get(from specifications: PackageSpecifications) -> [Product] {
    specifications.products
  }

  /// Updates the products in package specifications using a transform function.
  ///
  /// - Parameters:
  ///   - original: The original package specifications.
  ///   - transform: A function that transforms the array of products.
  /// - Returns: Updated package specifications with the transformed products.
  public static func update(original: PackageSpecifications, transform: ([Product]) -> [Product])
    -> PackageSpecifications
  {
    .init(
      products: transform(original.products),
      dependencies: original.dependencies,
      targets: original.targets,
      testTargets: original.testTargets,
      supportedPlatformSets: original.supportedPlatformSets,
      swiftSettings: original.swiftSettings,
      modifiers: original.modifiers
    )
  }
}
