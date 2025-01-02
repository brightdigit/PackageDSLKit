//
//  PackageSpecifications.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/2/25.
//

import PackageDSLKit

extension ProductType {
  init?(type: Package.Initialize.PackageType) {
    switch type {
    case .empty:
      return nil
    case .library:
      self = .library
    case .executable:
      self = .executable
    }
  }
}
extension Product {
  init?(name: String, type: Package.Initialize.PackageType) {
    guard let productType = ProductType(type: type) else {
      return nil
    }
    self.init(name: name, type: type)
  }
}

extension PackageSpecifications {
  init(name: String, type: Package.Initialize.PackageType) {
    let product = Product(name: name, type: type)
    let products = [product].compactMap{$0}
    self.init(products: products)
  }
}
