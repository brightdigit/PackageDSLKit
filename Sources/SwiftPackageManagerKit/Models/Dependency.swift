//
//  Dependency.swift
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

/// Represents a package dependency (can be source control or file system)
public enum Dependency: Codable, Hashable, Sendable {
  case sourceControl(SourceControlDependency)
  case fileSystem(FileSystemDependency)

  private enum CodingKeys: String, CodingKey {
    case sourceControl
    case fileSystem
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if container.contains(.sourceControl) {
      let sourceControlArray = try container.decode(
        [SourceControlDependency].self, forKey: .sourceControl)
      guard let dependency = sourceControlArray.first else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Empty source control dependency array")
        )
      }
      self = .sourceControl(dependency)
    } else if container.contains(.fileSystem) {
      let fileSystemArray = try container.decode([FileSystemDependency].self, forKey: .fileSystem)
      guard let dependency = fileSystemArray.first else {
        throw DecodingError.dataCorrupted(
          DecodingError.Context(
            codingPath: decoder.codingPath, debugDescription: "Empty file system dependency array")
        )
      }
      self = .fileSystem(dependency)
    } else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: decoder.codingPath, debugDescription: "Unknown dependency type")
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .sourceControl(let dependency):
      try container.encode([dependency], forKey: .sourceControl)
    case .fileSystem(let dependency):
      try container.encode([dependency], forKey: .fileSystem)
    }
  }

  public var identity: String {
    switch self {
    case .sourceControl(let dependency):
      return dependency.identity
    case .fileSystem(let dependency):
      return dependency.identity
    }
  }
}
