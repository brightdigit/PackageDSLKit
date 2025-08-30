//
//  TargetDependency.swift
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

/// Represents a target dependency (can be by name or product)
///
/// This enum defines the different ways a target can depend on other targets,
/// either by directly referencing a target name or by specifying a product
/// from a package. Each dependency can optionally include platform-specific
/// conditions.
public enum TargetDependency: Codable, Hashable, Sendable {
  /// A dependency on a target by its name, with optional platform conditions.
  case byName(String, condition: TargetDependencyCondition?)
  /// A dependency on a specific product from a package, with optional platform conditions.
  case product(String, String, condition: TargetDependencyCondition?)

  private enum CodingKeys: String, CodingKey {
    case byName
    case product
  }

  /// Creates a new TargetDependency instance from a decoder.
  ///
  /// - Parameter decoder: The decoder to read from.
  /// - Throws: A `DecodingError` if the target dependency type cannot be determined.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if container.contains(.byName) {
      var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .byName)
      let name = try unkeyedContainer.decode(String.self)
      _ = try? unkeyedContainer.decode(String?.self)  // Skip null value
      // TODO: Handle condition if needed
      let condition: TargetDependencyCondition? = nil
      self = .byName(name, condition: condition)
    } else if container.contains(.product) {
      var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .product)
      let productName = try unkeyedContainer.decode(String.self)
      let packageName = try unkeyedContainer.decode(String.self)
      _ = try? unkeyedContainer.decode(String?.self)  // Skip null value

      // Try to decode condition if present
      let condition: TargetDependencyCondition?
      if !unkeyedContainer.isAtEnd {
        condition = try? unkeyedContainer.decode(TargetDependencyCondition.self)
      } else {
        condition = nil
      }

      self = .product(productName, packageName, condition: condition)
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath, debugDescription: "Unknown target dependency type"
        )
      )
    }
  }

  /// Encodes the TargetDependency instance to an encoder.
  ///
  /// - Parameter encoder: The encoder to write to.
  /// - Throws: An error if the encoding fails.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .byName(let name, _):
      try container.encode([name, nil], forKey: .byName)
    case .product(let productName, let packageName, _):
      try container.encode([productName, packageName, nil, nil], forKey: .product)
    }
  }
}
