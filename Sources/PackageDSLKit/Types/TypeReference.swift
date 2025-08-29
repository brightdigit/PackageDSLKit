//
//  TypeReference.swift
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

/// A protocol for representing references to types within a Swift package.
///
/// This protocol defines the basic interface for any type reference, providing
/// a name property that can be used to identify and work with types.
public protocol TypeReference: Sendable, Hashable, Codable {
  /// The name of the referenced type.
  var name: String { get }
}

extension TypeReference {
  /// Converts the type reference to a function call string.
  ///
  /// This method generates a string representation of the type reference as a
  /// function call, appending empty parentheses to the type name.
  ///
  /// - Returns: A string representing the type reference as a function call.
  public func asFunctionCall() -> String {
    "\(name)()"
  }
}

extension BasicTypeReference {
  /// Creates a BasicTypeReference from a TypeSource.
  ///
  /// This convenience initializer creates a type reference using the type name
  /// from any object conforming to TypeSource.
  ///
  /// - Parameter source: The type source to create a reference from.
  public init(source: any TypeSource) {
    self.init(name: source.typeName)
  }
}
