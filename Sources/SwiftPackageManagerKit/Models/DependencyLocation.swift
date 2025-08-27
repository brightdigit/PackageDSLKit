//
//  DependencyLocation.swift
//  SwiftPackageManagerKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// Represents a dependency location (remote or file system)
public enum DependencyLocation: Codable, Hashable, Sendable {
  case remote(urlString: String)
  case fileSystem(path: String)

  private enum CodingKeys: String, CodingKey {
    case remote
    case fileSystem
  }

  private struct Remote: Codable, Sendable {
    let urlString: String
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if container.contains(.remote) {
      let remoteArray = try container.decode([Remote].self, forKey: .remote)
      guard let remote = remoteArray.first else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath, debugDescription: "Empty remote array")
        )
      }
      self = .remote(urlString: remote.urlString)
    } else if container.contains(.fileSystem) {
      let fileSystemPath = try container.decode(String.self, forKey: .fileSystem)
      self = .fileSystem(path: fileSystemPath)
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath, debugDescription: "Unknown dependency location type")
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .remote(let urlString):
      try container.encode([Remote(urlString: urlString)], forKey: .remote)
    case .fileSystem(let path):
      try container.encode(path, forKey: .fileSystem)
    }
  }
}
