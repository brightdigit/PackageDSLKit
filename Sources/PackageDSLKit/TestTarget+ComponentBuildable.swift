//
//  TestTarget+ComponentBuildable.swift
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

extension TestTarget: ComponentBuildable {
  static let directoryName: String = "Tests"
  static func requirements(from component: Component) -> ()? {
    guard component.inheritedTypes.contains("TestTarget") else {
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
    self.init(typeName: component.name, dependencies: dependencies)
  }

  func createComponent() -> Component {
    .init(
      name: self.typeName,
      inheritedTypes: ["TestTarget"],
      properties: [
        "dependencies": .init(
          name: "dependencies", type: "any Dependencies",
          code: dependencies.map { $0.asFunctionCall() })
      ]
    )
  }
}
//

//
// @available(*, deprecated)
// extension Set: ComponentBuildable where Element == SupportedPlatform {
//  init?(component: Component) {
//    guard component.inheritedTypes.contains("PlatformSet") else {
//      return nil
//    }
//    guard let body = component.properties["body"] else {
//      return nil
//    }
//    guard
//      body.type.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
//        == "any SupportedPlatforms"
//    else {
//      return nil
//    }
//    guard !body.code.isEmpty else {
//      return nil
//    }
//    let platformValues = body.code.map(SupportedPlatform.init)
//    let platforms = platformValues.compactMap { $0 }
//    assert(platforms.count == platformValues.count)
//    self.init(platforms)
//    //            ?.code, !body.isEmpty else {
//    //      return nil
//    //    }
//  }
//
//  func createComponent() -> Component {
//    fatalError()
//  }
// }
//
// extension Set : ComponentBuildable where Element == SwiftSetting {
//
// }
