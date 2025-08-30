//
//  Platform.swift
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

/// Represents a platform requirement in a Swift package
public struct Platform: Codable, Hashable, Sendable {
  /// The name of the platform (e.g., "macOS", "iOS", "Linux").
  public let platformName: String

  /// The minimum version requirement for this platform.
  public let version: String

  /// Additional platform-specific options or configurations.
  public let options: [String]

  /// Creates a new Platform instance with the specified configuration.
  ///
  /// - Parameters:
  ///   - platformName: The name of the platform.
  ///   - version: The minimum version requirement for this platform.
  ///   - options: Additional platform-specific options. Defaults to an empty array.
  public init(platformName: String, version: String, options: [String] = []) {
    self.platformName = platformName
    self.version = version
    self.options = options
  }
}
