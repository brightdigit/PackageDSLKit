//
//  ComponentBuildable.swift
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

/// A protocol for components that can be built with specific requirements.
///
/// This protocol defines the contract for components that can be constructed
/// from a base component and additional requirements, typically used for
/// creating specialized component instances.
internal protocol ComponentBuildable: Sendable {
  /// The type of requirements needed to build this component.
  /// Defaults to `Void` if no requirements are needed.
  associatedtype Requirements = Void

  /// The directory name associated with this component type.
  static var directoryName: String { get }

  /// Creates a new instance of this component with the given component and requirements.
  ///
  /// - Parameters:
  ///   - component: The base component to build from.
  ///   - requirements: The specific requirements for building this component.
  init(component: Component, requirements: Requirements)

  /// Extracts requirements from a component if possible.
  ///
  /// - Parameter component: The component to extract requirements from.
  /// - Returns: The extracted requirements, or `nil` if extraction is not possible.
  static func requirements(from component: Component) -> Requirements?

  // func createComponent() -> Component
}
