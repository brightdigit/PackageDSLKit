//
//  ComponentBuildable.swift
//  PackageDSLKit
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

internal protocol ComponentBuildable {
  associatedtype Requirements = Void
  init(component: Component, requirements: Requirements)
  func createComponent() -> Component
  static func requirements(from component: Component) -> Requirements?
  static var directoryName: String { get }
}

extension ComponentBuildable {
  internal init?(component: Component) {
    guard let requirements = Self.requirements(from: component) else { return nil }
    self.init(component: component, requirements: requirements)
  }

  internal static func directoryURL(relativeTo packageDSLURL: URL) -> URL {
    packageDSLURL.appending(path: self.directoryName, directoryHint: .isDirectory)
  }
}

extension Component {
  func isType<T: ComponentBuildable>(of type: T.Type) -> Bool {
    type.requirements(from: self) != nil
  }
}
