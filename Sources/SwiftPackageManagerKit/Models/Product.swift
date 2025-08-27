//
//  Product.swift
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

/// Represents a product in a Swift package
public struct Product: Codable, Hashable, Sendable {
  public let name: String
  public let type: ProductType
  public let targets: [String]
  public let settings: [String]  // Product-specific settings

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

  // Custom decoding to handle missing settings field
  public init(from decoder: Decoder) throws {
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

  private enum CodingKeys: String, CodingKey {
    case name, type, targets, settings
  }
}
