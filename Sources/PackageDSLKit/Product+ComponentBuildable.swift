//
//  Product+ComponentBuildable.swift
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

extension Product: ComponentBuildable {
  static let directoryName: String = "Products"
  static func requirements(from component: Component) -> ()? {
    guard component.inheritedTypes.contains("Product") else {
      return nil
    }
    return ()
  }
  init(component: Component, requirements: Void) {
    let dependencies =
      component.properties["dependencies"]?.code.map { line in
        DependencyRef(
          name: line.filter({ character in
            character.isLetter || character.isNumber
          }))
      } ?? []
    let name = component.properties["name"]?.code.first
    let productType = component.properties["productType"]?.code.compactMap(
      ProductType.init(rawValue:)
    ).first

    self.init(
      typeName: component.name,
      name: name,
      dependencies: dependencies,
      productType: productType
    )
  }

  func createComponent() -> Component {
    .init(
      name: typeName,
      inheritedTypes: ["Product", "Target"],
      properties: [
        "name": .init(name: "name", type: "String", code: [name]),
        "dependencies": .init(
          name: "dependencies", type: "any Dependencies",
          code: dependencies.map { $0.asFunctionCall() }),
        "productType": .init(
          name: "productType", type: "ProductType",
          code: [
            productType.map {
              ".\($0.rawValue)"
            }
          ]),
      ].compactMapValues { $0 }
    )
  }
}
