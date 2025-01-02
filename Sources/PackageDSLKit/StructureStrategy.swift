//
//  StructureStrategy.swift
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

import SwiftSyntax

#if canImport(os)
  import os
#elseif canImport(Logging)
  import Logging
#endif

// Strategy for structure parsing
class StructureStrategy: ParsingStrategy {
  private var name: String?
  private var inheritedTypes: [String] = []

  private var properties = [Property]()
  func finalize() -> ParsingResult? {
    let propertyDictionary = Dictionary(grouping: self.properties) { property in
      property.name
    }.compactMapValues { properties in
      assert(properties.count == 1)
      return properties.first
    }
    return .structure(
      .init(
        name: name ?? "",
        inheritedTypes: inheritedTypes,
        properties: propertyDictionary
      )
    )
  }

  func reset() {
    name = nil
    inheritedTypes = []
    properties = []
    // structureData.removeAll()
  }

  #if canImport(os)
    private let logger = Logger(subsystem: "packagedsl", category: "structure")
  #elseif canImport(Logging)
    private let logger = Logger(label: "structure")
  #endif

  func shouldActivate(_ node: some SyntaxProtocol, currentStrategy: ParsingStrategy?) -> Bool {
    // Don't activate if there's already a StructureStrategy
    if currentStrategy is StructureStrategy {
      return false
    }

    return node.is(StructDeclSyntax.self)
  }

  func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
    let visitor = PropertyVisitor(viewMode: .fixedUp)
    let property: Property
    do {
      property = try visitor.parse(node)
    } catch {
      logger.error("Error parsing property \(node): \(error)")
      return .skipChildren
    }
    self.properties.append(property)
    return .skipChildren
  }

  func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
    self.inheritedTypes.append(node.type.trimmedDescription)
    return .skipChildren
  }

  func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    self.name = node.name.text
    return .visitChildren
  }
}
