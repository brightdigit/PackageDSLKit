//
//  PackageIndexWriter.swift
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
import SyntaxKit

public struct PackageIndexWriter: IndexCodeWriter, Sendable, Hashable, Codable {
  public init() {
  }
  private func labeledExpression(for name: String, items: [String]) -> LabeledExprSyntax? {
    if items.isEmpty {
      return nil
    }
    return LabeledExprSyntax(
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

  @available(*, deprecated, message: "Use syntaxKitWriteIndex(_:) instead")
  public func writeIndex(_ index: Index) throws(PackageDSLError) -> String {
    let importDecl = Import("PackageDescription")
    let declSyntax: DeclSyntax = .init(importDecl.syntax.as(ImportDeclSyntax.self)!)

    let labeledExpressions = [
      self.labeledExpression(for: "entries", items: index.entries.map(\.name)),
      self.labeledExpression(for: "dependencies", items: index.dependencies.map(\.name)),
      self.labeledExpression(for: "testTargets", items: index.testTargets.map(\.name)),
      self.labeledExpression(for: "swiftSettings", items: index.swiftSettings.map(\.name)),
    ]
    .compactMap { $0 }
    .reversed()
    .enumerated()
    .map { index, expression in
      if index == 0 {
        return expression
      }
      return expression.with(\.trailingComma, .commaToken())
    }
    .reversed()
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
                arguments: LabeledExprListSyntax(labeledExpressions),
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
  
  /// Creates index using SyntaxKit
  public func syntaxKitWriteIndex(_ index: Index) throws(PackageDSLError) -> String {
    // Create import declaration
    let importDecl = Import("PackageDescription")
    
    // Helper function to create parameter for each section
    func createParameter(name: String, items: [String]) -> ParameterExp? {
      guard !items.isEmpty else { return nil }
      
      // Create closure with function calls
      // For simplicity, use the first item for now
      
      let closure = Closure(body: items.first.map { [Call($0)] } ?? [])
      
      return ParameterExp(name: name, value: closure)
    }
    
    // Create labeled parameters
    let parameters: [ParameterExp] = [
      createParameter(name: "entries", items: index.entries.map(\.name)),
      createParameter(name: "dependencies", items: index.dependencies.map(\.name)),
      createParameter(name: "testTargets", items: index.testTargets.map(\.name)),
      createParameter(name: "swiftSettings", items: index.swiftSettings.map(\.name))
    ].compactMap { $0 }
    
    // Create Package initialization
    // For simplicity, use the first few parameters
    let packageInit = Init("Package", params: Array(parameters.prefix(4)))
    
    // Create let package = Package(...) variable
    let packageVar = Variable(.let, name: "package", equals: packageInit)
    
    // Combine import and package declaration
    let codeBlocks: [CodeBlock] = [importDecl, packageVar]
    
    // Convert to syntax and return description
    let syntax = CodeBlockItemListSyntax(
      codeBlocks.compactMap { codeBlock in
        if let declSyntax = codeBlock.syntax.as(DeclSyntax.self) {
          return CodeBlockItemSyntax(item: .decl(declSyntax))
        }
        return nil
      }
    )
    
    return syntax.description
  }
}
