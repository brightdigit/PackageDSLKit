//
//  ResourceRule.swift
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

/// Represents resource rules for targets
public enum ResourceRule: Codable, Hashable, Sendable {
  case copy
  case process

  private enum CodingKeys: String, CodingKey {
    case copy
    case process
  }

  /// Decodes the resource rules for targets from the Decoder.
  /// - Parameter decoder:Decoder.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if container.contains(.copy) {
      self = .copy
    } else if container.contains(.process) {
      self = .process
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath, debugDescription: "Unknown resource rule type"
        )
      )
    }
  }

  /// Encodes this ResourceRule instance to an encoder.
  ///
  /// This method handles the encoding logic for different resource rule types,
  /// which are encoded as presence indicators with empty dictionaries as values.
  ///
  /// - Parameter encoder: The encoder to write to.
  /// - Throws: An error if the encoding fails.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .copy:
      try container.encode([String: String](), forKey: .copy)
    case .process:
      try container.encode([String: String](), forKey: .process)
    }
  }
}
