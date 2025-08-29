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

import Foundation

/// Represents a product in a Swift package
public struct Product: Codable, Hashable, Sendable {
  private enum CodingKeys: String, CodingKey {
    case name, type, targets, settings
  }

  /// The name of the product.
  public let name: String

  /// The type of the product (library, executable, plugin, etc.).
  public let type: ProductType

  /// The target names that this product depends on.
  public let targets: [String]

  /// Product-specific settings as string key-value pairs.
  public let settings: [String]

  /// Creates a new Product instance with the specified configuration.
  ///
  /// - Parameters:
  ///   - name: The name of the product.
  ///   - type: The type of the product.
  ///   - targets: The target names that this product depends on.
  ///   - settings: Product-specific settings. Defaults to an empty array.
  public init(
    name: String,
    type: ProductType,
    targets: [String],
    settings: [String] = []
  ) {
    self.name = name
    self.type = type
    self.targets = targets
    self.settings = settings
  }

  /// Creates a new Product instance from a decoder.
  ///
  /// This initializer handles custom decoding to gracefully handle missing optional fields
  /// by providing sensible defaults when certain keys are not present in the decoded data.
  ///
  /// - Parameter decoder: The decoder to read from.
  /// - Throws: A `DecodingError` if required fields cannot be decoded.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.name = try container.decode(String.self, forKey: .name)
    self.type = try container.decode(ProductType.self, forKey: .type)
    self.targets = try container.decode([String].self, forKey: .targets)

    // Handle missing settings field gracefully
    if container.contains(.settings) {
      self.settings = try container.decode([String].self, forKey: .settings)
    } else {
      self.settings = []
    }
  }
}
