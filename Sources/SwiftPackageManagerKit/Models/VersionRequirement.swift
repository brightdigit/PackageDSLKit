//
//  VersionRequirement.swift
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

/// Represents version requirements for dependencies
public enum VersionRequirement: Codable, Hashable, Sendable {
  case range(lowerBound: String, upperBound: String)
  case exact(String)
  case revision(String)
  case branch(String)

  private enum CodingKeys: String, CodingKey {
    case range
    case exact
    case revision
    case branch
  }

  private enum RangeKeys: String, CodingKey {
    case lowerBound
    case upperBound
  }

  private struct RangeInfo: Codable, Sendable {
    let lowerBound: String
    let upperBound: String
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if container.contains(.range) {
      // The range is an array with one object containing lowerBound and upperBound
      let rangeArray = try container.decode([RangeInfo].self, forKey: .range)
      guard let rangeInfo = rangeArray.first else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath, debugDescription: "Empty range array")
        )
      }
      self = .range(lowerBound: rangeInfo.lowerBound, upperBound: rangeInfo.upperBound)
    } else if let exact = try? container.decode(String.self, forKey: .exact) {
      self = .exact(exact)
    } else if let revision = try? container.decode(String.self, forKey: .revision) {
      self = .revision(revision)
    } else if let branch = try? container.decode(String.self, forKey: .branch) {
      self = .branch(branch)
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath, debugDescription: "Unknown version requirement type")
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .range(let lowerBound, let upperBound):
      var rangeContainer = container.nestedContainer(keyedBy: RangeKeys.self, forKey: .range)
      try rangeContainer.encode(lowerBound, forKey: .lowerBound)
      try rangeContainer.encode(upperBound, forKey: .upperBound)
    case .exact(let version):
      try container.encode(version, forKey: .exact)
    case .revision(let revision):
      try container.encode(revision, forKey: .revision)
    case .branch(let branch):
      try container.encode(branch, forKey: .branch)
    }
  }
}
