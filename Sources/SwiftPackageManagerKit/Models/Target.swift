//
//  Target.swift
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

/// Represents a target in a Swift package
public struct Target: Codable, Hashable, Sendable {
  private enum CodingKeys: String, CodingKey {
    case name, type, dependencies, exclude, resources, settings, packageAccess
  }

  public let name: String
  public let type: TargetType
  public let dependencies: [TargetDependency]
  public let exclude: [String]
  public let resources: [Resource]
  public let settings: [String]  // Target-specific settings
  public let packageAccess: Bool

  public init(
    name: String,
    type: TargetType,
    dependencies: [TargetDependency] = [],
    exclude: [String] = [],
    resources: [Resource] = [],
    settings: [String] = [],
    packageAccess: Bool = true
  ) {
    self.name = name
    self.type = type
    self.dependencies = dependencies
    self.exclude = exclude
    self.resources = resources
    self.settings = settings
    self.packageAccess = packageAccess
  }

  // Custom decoding to handle missing optional fields gracefully
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.name = try container.decode(String.self, forKey: .name)
    self.type = try container.decode(TargetType.self, forKey: .type)
    self.dependencies = try container.decode([TargetDependency].self, forKey: .dependencies)

    // Handle missing optional fields gracefully
    if container.contains(.exclude) {
      self.exclude = try container.decode([String].self, forKey: .exclude)
    } else {
      self.exclude = []
    }

    if container.contains(.resources) {
      self.resources = try container.decode([Resource].self, forKey: .resources)
    } else {
      self.resources = []
    }

    if container.contains(.settings) {
      self.settings = try container.decode([String].self, forKey: .settings)
    } else {
      self.settings = []
    }

    if container.contains(.packageAccess) {
      self.packageAccess = try container.decode(Bool.self, forKey: .packageAccess)
    } else {
      self.packageAccess = true
    }
  }
}
