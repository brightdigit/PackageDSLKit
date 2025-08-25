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
  internal func testSyntaxKitNodeGeneration(index: Int) async {
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
    
    // Test that ComponentWriter can generate SyntaxKit nodes without using deprecated APIs
    let writer = ComponentWriter()
    let component = Component(
      name: .randomIdentifier(),
      inheritedTypes: [.randomIdentifier(), .randomIdentifier()],
      properties: propertyDictionary
    )
    let syntaxKitStruct = writer.syntaxKitNode(from: component)
    
    // Verify the struct was created with the expected name and properties
    #expect(syntaxKitStruct.syntax.description.contains(component.name))
    
    // Verify properties are included in the generated syntax
    for property in propertyValues {
      #expect(syntaxKitStruct.syntax.description.contains(property.name))
      #expect(syntaxKitStruct.syntax.description.contains(property.type))
    }
    
    // Verify inheritance is included
    for inheritedType in component.inheritedTypes {
      #expect(syntaxKitStruct.syntax.description.contains(inheritedType))
    }
  }
}
