//
//  Test 2.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/3/25.
//

import Foundation
import Testing

@testable import PackageDSLKit

internal struct ComponentBuildableTests {
  @Test(arguments: zip(1...100, [true, false])) internal func initialize(
    index: Int, containsRequirements: Bool
  ) throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let name = UUID().uuidString
    let component = MockComponentBuildable.component(
      name: name,
      containsRequirements: containsRequirements
    )
    let result = MockComponentBuildable(
      component: component
    )

    guard containsRequirements else {
      try #require(result == nil)
      return
    }

    #expect(result?.component == component)
  }

  @Test(arguments: 1...100)
  internal func directoryURL(index: Int) async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let packageDSLName = UUID().uuidString
    let packageDSLURL = URL.temporaryDirectory.appending(
      path: packageDSLName, directoryHint: .isDirectory)
    let componentDirectoryURL = MockComponentBuildable.directoryURL(relativeTo: packageDSLURL)

    let expectedDirectoryName = componentDirectoryURL.lastPathComponent
    let expectedPackageDSLURL = componentDirectoryURL.deletingLastPathComponent()
    let expectedPackageDSLName = expectedPackageDSLURL.lastPathComponent

    #expect(MockComponentBuildable.directoryName == expectedDirectoryName)
    #expect(expectedPackageDSLURL == packageDSLURL)
    #expect(expectedPackageDSLName == packageDSLName)
  }

  @Test(arguments: zip(1...100, [true, false]))
  internal func isType(index: Int, containsRequirements: Bool) async throws {
    let name = UUID().uuidString
    let component = MockComponentBuildable.component(
      name: name, containsRequirements: containsRequirements)
    let isType = component.isType(of: MockComponentBuildable.self)
    #expect(isType == containsRequirements)
  }
}
