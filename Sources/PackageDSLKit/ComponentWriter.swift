//
//  ComponentWriter.swift
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

public struct ComponentWriter: Sendable, StructureWriter {
  private let propertyWriter: @Sendable (Property) -> VariableDeclSyntax

  public init(
    propertyWriter: @escaping @Sendable (Property) -> VariableDeclSyntax = PropertyWriter.node
  ) {
    self.propertyWriter = propertyWriter
  }

  public func node(from component: Component) -> StructDeclSyntax {
    let memberBlockList = MemberBlockItemListSyntax(
      component.properties.values.map(propertyWriter).map {
        MemberBlockItemSyntax(decl: $0)
      }
    )
    let inheritedTypes = component.inheritedTypes
      .map { TokenSyntax.identifier($0) }
      .map {
        IdentifierTypeSyntax(name: $0)
      }
      .map {
        InheritedTypeSyntax(type: $0)
      }
      .reversed()
      .enumerated()
      .map { index, expression in
        if index == 0 {
          return expression
        }
        return expression.with(\.trailingComma, .commaToken())
      }
      .reversed()
    let inheritedTypeList = InheritedTypeListSyntax(inheritedTypes)
    let clause = InheritanceClauseSyntax(inheritedTypes: inheritedTypeList)
    let memberBlock = MemberBlockSyntax(members: memberBlockList)
    return StructDeclSyntax(
      name: .identifier(component.name, leadingTrivia: .space),
      inheritanceClause: clause,
      memberBlock: memberBlock
    )
  }
}
