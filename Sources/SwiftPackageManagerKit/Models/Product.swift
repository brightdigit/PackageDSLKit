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

public import Foundation

/// Represents product type in a Swift package
public enum ProductType: Codable, Hashable, Sendable {
  case library(LibraryType)
  case executable
  case plugin

  public enum LibraryType: String, Codable, Hashable, Sendable {
    case automatic
    case dynamic
    case `static`
  }

  private enum CodingKeys: String, CodingKey {
    case library
    case executable
    case plugin
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let libraryTypes = try? container.decode([LibraryType].self, forKey: .library) {
      let libraryType = libraryTypes.first ?? .automatic
      self = .library(libraryType)
    } else if container.contains(.executable) {
      self = .executable
    } else if container.contains(.plugin) {
      self = .plugin
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath, debugDescription: "Unknown product type")
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .library(let libraryType):
      try container.encode([libraryType], forKey: .library)
    case .executable:
      try container.encode([String](), forKey: .executable)
    case .plugin:
      try container.encode([String](), forKey: .plugin)
    }
  }
}

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
}
