//
//  Models.swift
//  SyntaxKit
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

import Foundation

// Note: This file provides convenience extensions for SPM models
// All model types are available through their individual files

/// Convenience extensions for working with SPM models
extension PackageInfo {
  /// Find a target by name
  public func target(named name: String) -> Target? {
    targets.first { $0.name == name }
  }

  /// Find a product by name
  public func product(named name: String) -> Product? {
    products.first { $0.name == name }
  }

  /// Get all library products
  public var libraryProducts: [Product] {
    products.filter {
      if case .library = $0.type {
        return true
      }
      return false
    }
  }

  /// Get all executable products
  public var executableProducts: [Product] {
    products.filter {
      if case .executable = $0.type {
        return true
      }
      return false
    }
  }
}

extension Target {
  /// Get all product dependencies
  public var productDependencies: [String] {
    dependencies.compactMap {
      if case .product(let productName, _, _) = $0 {
        return productName
      }
      return nil
    }
  }

  /// Get all by-name dependencies
  public var byNameDependencies: [String] {
    dependencies.compactMap {
      if case .byName(let name, _) = $0 {
        return name
      }
      return nil
    }
  }
}

extension Dependency {
  /// Get the URL string for remote dependencies
  public var urlString: String? {
    switch self {
    case .sourceControl(let dep):
      if case .remote(let url) = dep.location {
        return url
      }
    case .fileSystem:
      return nil
    }
    return nil
  }

  /// Get the file path for local dependencies
  public var filePath: String? {
    switch self {
    case .sourceControl:
      return nil
    case .fileSystem(let dep):
      return dep.path
    }
  }
}
