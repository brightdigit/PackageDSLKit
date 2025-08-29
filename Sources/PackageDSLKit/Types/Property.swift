//
//  Property.swift
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

/// Represents a property definition with its name, type, and implementation code.
///
/// This structure encapsulates a property's metadata including its name, type information,
/// and the Swift code lines that implement the property.
public struct Property: Sendable, Hashable, Codable {
  /// The name of the property.
  public let name: String

  /// The type of the property as a string.
  public let type: String

  /// An array of Swift code lines that implement the property.
  public let code: [String]

  /// Creates a new property with the specified name, type, and implementation code.
  ///
  /// - Parameters:
  ///   - name: The name of the property.
  ///   - type: The type of the property as a string.
  ///   - code: An array of Swift code lines that implement the property.
  public init(
    name: String,
    type: String,
    code: [String]
  ) {
    self.name = name
    self.type = type
    self.code = code
  }
}
