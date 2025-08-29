//
//  DependencyType.swift
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

/// Represents the type of dependency
///
/// This struct uses an option set to represent different types of dependencies
/// that can be combined to create complex dependency relationships.
public struct DependencyType: OptionSet, Sendable, Hashable, Codable {
  /// The raw integer value representing the dependency type
  public typealias RawValue = Int

  internal struct InvalidValueError: Error, Sendable {
    internal let invalidCount: Int

    internal init?(invalidCount: Int) {
      guard invalidCount != 0 else {
        return nil
      }
      assert(invalidCount > 0)
      self.invalidCount = invalidCount
    }

    internal init?(valuesCount: Int, indiciesCount: Int) {
      self.init(invalidCount: indiciesCount - valuesCount)
    }
  }

  /// Represents a package dependency
  public static let package = DependencyType(rawValue: 1)
  /// Represents a target dependency
  public static let target = DependencyType(rawValue: 2)
  private static let strings: [String] = ["PackageDependency", "TargetDependency"]

  /// The raw integer value of this dependency type
  public var rawValue: Int

  /// Creates a new dependency type with the specified raw value
  ///
  /// - Parameter rawValue: The integer value representing the dependency type
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  internal init?(stringsThrows strings: [String]) throws(InvalidValueError) {
    let indicies = strings.map {
      Self.strings.firstIndex(of: $0)
    }
    let rawValues = indicies.compactMap(\.self).map { $0 + 1 }
    if rawValues.isEmpty {
      return nil
    }
    if let error = InvalidValueError(valuesCount: rawValues.count, indiciesCount: indicies.count) {
      assert(error.invalidCount > 0)
      throw error
    }
    let rawValue = rawValues.reduce(0) { $0 + $1 }
    self.init(rawValue: rawValue)
  }

  /// Creates a dependency type from an array of string representations
  ///
  /// - Parameter strings: Array of strings representing dependency types
  ///
  /// - Returns: A dependency type if the strings are valid, nil otherwise
  public init?(strings: [String]) {
    do {
      try self.init(stringsThrows: strings)
    } catch {
      assertionFailure("Invalid Values Passed: \(error.invalidCount)")
      return nil
    }
  }

  internal func asInheritedTypes() -> [String] {
    rawValue.powerOfTwoExponents().map { Self.strings[$0] }
  }
}

extension Int {
  fileprivate func powerOfTwoExponents() -> [Int] {
    var number = self
    var exponents: [Int] = []
    var currentExponent = 0

    while number > 0 {
      if number & 1 == 1 {
        exponents.append(currentExponent)
      }
      number >>= 1
      currentExponent += 1
    }

    return exponents
  }
}
