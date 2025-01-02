//
//  Dependency+ComponentBuildable.swift
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

extension Dependency: ComponentBuildable {
  internal typealias Requirements = DependencyType
  public static let directoryName: String = "Dependencies"

  internal static func requirements(from component: Component) -> DependencyType? {
    guard let dependencyType = DependencyType(strings: component.inheritedTypes) else {
      return nil
    }
    guard dependencyType.rawValue > 0 else {
      return nil
    }
    return dependencyType
  }
  internal init(component: Component, requirements: Requirements) {
    let package =
      (component.properties["dependencies"]?.code.first?.filter({ character in
        character.isLetter || character.isNumber
      })).map(DependencyRef.init)

    self.init(
      typeName: component.name,
      type: requirements,
      dependency: component.properties["dependency"]?.code.first,
      package: package
    )
  }

  internal func createComponent() -> Component {
    var properties = [String: Property]()
    let inheritedTypes: [String]
    let name: String

    name = typeName
    inheritedTypes = self.type.asInheritedTypes()

    if let dependency {
      properties["dependency"] = Property(
        name: "dependency", type: "Package.Dependency", code: [dependency])
    }

    if let package {
      properties["package"] = Property(
        name: "package", type: "PackageDependency", code: [package.asFunctionCall()]
      )
    }

    return .init(name: name, inheritedTypes: inheritedTypes, properties: properties)
  }
}
