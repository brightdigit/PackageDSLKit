//
//  PackageWriter.swift
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

import Foundation
import SwiftSyntax

public struct PackageIndexWriter {
  public func labeledExpression(for name: String, items: [String]) -> LabeledExprSyntax {
    LabeledExprSyntax(
      leadingTrivia: .newline,
      label: .identifier(name),
      colon: .colonToken(trailingTrivia: .space),
      expression: ClosureExprSyntax(
        statements: CodeBlockItemListSyntax(
          items.map { name in
            CodeBlockItemSyntax(
              item: .expr(
                ExprSyntax(
                  FunctionCallExprSyntax(
                    leadingTrivia: .newline,
                    calledExpression: DeclReferenceExprSyntax(baseName: .identifier(name)),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax([]),
                    rightParen: .rightParenToken(),
                    trailingTrivia: .init(.newline)
                  )
                )
              )
            )
          }
        )
      ),
      trailingTrivia: .newline
    )
  }

  public func writeIndex(_ index: Index) throws -> String {
    let declSyntax: DeclSyntax = .init(ImportDeclSyntax.module("PackageDescription"))

    let packageDecl = VariableDeclSyntax(
      leadingTrivia: .newline,
      bindingSpecifier: .keyword(.let),
      bindings: PatternBindingListSyntax([
        PatternBindingSyntax(
          pattern: IdentifierPatternSyntax(
            leadingTrivia: .space,
            identifier: .identifier("package"),
            trailingTrivia: .space
          ),
          initializer: InitializerClauseSyntax(
            value:
              FunctionCallExprSyntax(
                leadingTrivia: .space,
                calledExpression: DeclReferenceExprSyntax(baseName: .identifier("Package")),
                leftParen: .leftParenToken(),
                arguments: LabeledExprListSyntax([
                  self.labeledExpression(for: "entries", items: ["FODWorkout"])
                ]),
                rightParen: .rightParenToken()
              )
          )
        )
      ])
    )
    let syntax = CodeBlockItemListSyntax([
      CodeBlockItemSyntax(item: .decl(declSyntax)),
      CodeBlockItemSyntax(item: .decl(DeclSyntax(packageDecl))),
    ])
    return syntax.description
  }
}

public struct PackageWriter {
  let indexWriter: PackageIndexWriter = .init()
  func write(_ specification: PackageSpecifications, to url: URL) throws(PackageDSLError) {
    let configuration = PackageDirectoryConfiguration(specifications: specification)

    let indexFileURL = url.appending(component: "Index.swift")
    do {
      try indexWriter.writeIndex(configuration.index).write(
        to: indexFileURL, atomically: true, encoding: .utf8)
    } catch {
      throw .other(error)
    }
    let components = configuration.createComponents()
    for component in components {
    }
  }
}
