//
//  PackagePropertyDescriptor.swift
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

/// A protocol that describes package properties and provides methods for retrieving and updating them.
///
/// This protocol defines the contract for package property descriptors that can extract specific
/// property types from package specifications and update them with transformations.
public protocol PackagePropertyDescriptor: Sendable {
  /// Retrieves all instances of this property type from the given package specifications.
  ///
  /// - Parameter specifications: The package specifications to extract properties from.
  /// - Returns: An array of property instances found in the specifications.
  static func get(from specifications: PackageSpecifications) -> [Self]

  /// Updates the original package specifications by transforming the properties of this type.
  ///
  /// - Parameters:
  ///   - original: The original package specifications to update.
  ///   - transform: A closure that transforms the array of properties.
  /// - Returns: Updated package specifications with the transformed properties.
  static func update(original: PackageSpecifications, transform: ([Self]) -> [Self])
    -> PackageSpecifications
}
