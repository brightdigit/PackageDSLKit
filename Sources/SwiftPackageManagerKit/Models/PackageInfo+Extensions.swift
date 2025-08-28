//
//  PackageInfo+Extensions.swift
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

import Foundation

/// Convenience extensions for working with PackageInfo
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
