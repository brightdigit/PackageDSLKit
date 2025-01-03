//
//  ComponentWriterTests.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/3/25.
//

import Testing

@testable import PackageDSLKit

internal struct ComponentWriterTests {
  private final class Indicies: @unchecked Sendable {
    private var set: Set<Int> = .init()

    fileprivate func contains(_ index: Int) -> Bool {
      set.contains(index)
    }

    fileprivate func insert(_ index: Int) {
      set.insert(index)
    }
  }

  @Test(arguments: 1...100)
  internal func testPropertyCalls(index: Int) async {
    let propertyValues: [Property] = (1...5).map { _ in
      .init(
        name: .randomIdentifier(),
        type: .randomIdentifier(),
        code: [
          .randomIdentifier(),
          .randomIdentifier(),
        ]
      )
    }
    let propertyDictionary: [String: Property] = .init(
      uniqueKeysWithValues: propertyValues.map {
        ($0.name, $0)
      }
    )
    await confirmation(expectedCount: propertyValues.count) { confirmation in
      let indicies = Indicies()
      let writer = ComponentWriter { actualProperty in
        // swiftlint:disable:next force_try
        let actualIndex = try! #require(propertyValues.firstIndex(of: actualProperty))
        #expect(!indicies.contains(actualIndex))
        indicies.insert(actualIndex)
        defer {
          confirmation()
        }
        return PropertyWriter.node(from: actualProperty)
      }
      let component = Component(
        name: .randomIdentifier(),
        inheritedTypes: [.randomIdentifier(), .randomIdentifier()],
        properties: propertyDictionary
      )
      _ = writer.node(from: component)
    }
  }
}
