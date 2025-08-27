//
//  MockComponentBuildable.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/3/25.
//

import Foundation

@testable import PackageDSLKit

internal struct MockComponentBuildable: ComponentBuildable {
  internal static let directoryName: String = UUID().uuidString

  internal let component: PackageDSLKit.Component

  internal init(component: PackageDSLKit.Component, requirements: ()) {
    self.component = component
  }

  internal static func requirements(from component: PackageDSLKit.Component) -> ()? {
    guard component.properties["containsRequirements"] != nil else {
      return nil
    }
    return ()
  }

  internal static func component(name: String, containsRequirements: Bool) -> Component {
    var properties = [String: Property]()
    if containsRequirements {
      properties[
        "containsRequirements"] =
        Property(
          name: "containsRequirements",
          type: "type",
          code: ["code"]
        )
    }
    return Component(
      name: name,
      inheritedTypes: [],
      properties: properties
    )
  }

  internal func createComponent() -> PackageDSLKit.Component {
    component
  }
}
