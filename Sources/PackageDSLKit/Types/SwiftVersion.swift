//
//  SwiftVersion.swift
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

/// A Swift version representation with major and minor components
///
/// This struct represents a Swift version in the format "major.minor" (e.g., "5.9").
/// It provides parsing from strings and can be used in string literals.
public struct SwiftVersion: Sendable, Hashable, ExpressibleByStringLiteral, CustomStringConvertible
{
  internal struct ParsingError: OptionSet, Error, Sendable {
    internal static let major: ParsingError = .init(rawValue: 1 << 0)
    internal static let minor: ParsingError = .init(rawValue: 1 << 1)

    internal let rawValue: Int

    internal init(rawValue: Int) {
      self.rawValue = rawValue
    }

    fileprivate init?(major: Int?, minor: Int?) {
      var error = ParsingError()

      if major == nil {
        error.insert(.major)
      }

      if minor == nil {
        error.insert(.minor)
      }

      guard error.rawValue > 0 else {
        return nil
      }
      self = error
    }
  }

  /// The major version number
  public let major: Int
  /// The minor version number
  public let minor: Int

  /// A string representation of the version in "major.minor" format
  public var description: String {
    [major, minor].map(\.description).joined(separator: ".")
  }

  /// Creates a new Swift version
  ///
  /// - Parameters:
  ///   - major: The major version number
  ///   - minor: The minor version number
  public init(major: Int, minor: Int) {
    self.major = major
    self.minor = minor
  }

  internal init(throwing value: String) throws(ParsingError) {
    let components = value.components(separatedBy: ".")
    let major: Int? = .init(components[0])
    let minor: Int? = .init(components[1])
    try self.init(major: major, minor: minor)
  }

  internal init(major: Int?, minor: Int?) throws(ParsingError) {
    if let major = major, let minor = minor {
      self.init(major: major, minor: minor)
    } else if let error = ParsingError(major: major, minor: minor) {
      throw error
    } else {
      assertionFailure("Should never reach here")
      throw .init(rawValue: 0)
    }
  }

  /// Creates a Swift version from a string literal
  ///
  /// - Parameter value: The version string in "major.minor" format
  ///
  /// - Note: This initializer will crash if the string format is invalid.
  ///   Use `init(throwing:)` for safe parsing.
  public init(stringLiteral value: String) {
    do {
      try self.init(throwing: value)
    } catch {
      fatalError("Invalid String Literal: \(value)")
    }
  }
}
