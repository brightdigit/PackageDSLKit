//
//  SupportedPlatformSet.swift
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

public struct SupportedPlatformSet: TypeSource, ComponentBuildable {
  static func requirements(from component: Component) -> Property? {
    guard component.inheritedTypes.contains("PlatformSet") else {
      return nil
    }
    guard let body = component.properties["body"] else {
      return nil
    }
    guard
      body.type.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        == "any SupportedPlatforms"
    else {
      return nil
    }
    guard !body.code.isEmpty else {
      return nil
    }
    return body
  }
  
  public init(typeName: String, platforms: Set<SupportedPlatform>) {
    self.typeName = typeName
    self.platforms = platforms
  }

  init (component: Component, requirements: Requirements) {

    

    let platformValues = requirements.code.map(SupportedPlatform.init)
    let platforms = platformValues.compactMap { $0 }
    assert(platforms.count == platformValues.count)
    self.init(
      typeName: component.name,
      platforms: .init(platforms)
    )
  }

  func createComponent() -> Component {
    .init(
      name: self.typeName,
      inheritedTypes: ["PlatformSet"],
      properties: [
        "body": .init(
          name: "body", type: "any SupportedPlatforms", code: self.platforms.map(\.code))
      ]
    )
  }

  public let typeName: String
  public let platforms: Set<SupportedPlatform>
}
