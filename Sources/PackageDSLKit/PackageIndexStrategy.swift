//
//  PackageIndexStrategy.swift
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

internal class PackageIndexStrategy: ParsingStrategy {
  internal enum ExpressionKind: String {
    case entries
    case dependencies
    case testTargets
    case swiftSettings
  }

  private enum VisitorState: Equatable {
    case root
    case variable
    case functionCall
    case labeledExpr(ExpressionKind)
    case codeBlockFor(ExpressionKind)
    case modifier(ModifierType)
  }

  private var items = [(ExpressionKind, String)]()
  private var modifiers = [ModifierType: [String]]()
  private var currentState: VisitorState = .root
  #if canImport(os)
    private let logger = Logger(subsystem: "packagedsl", category: "structure")
  #elseif canImport(Logging)
    private let logger = Logger(label: "structure")
  #endif

  internal func finalize() -> ParsingResult? {
    let result = ParsingResult.packageIndex(items, modifiers)
    return result
  }

  internal func reset() {
    items.removeAll()
    modifiers.removeAll()
    currentState = .root
  }

  internal func shouldActivate(_ node: some SyntaxProtocol, currentStrategy: ParsingStrategy?)
    -> Bool
  {
    // Don't activate if there's already a PackageIndexStrategy
    if currentStrategy is PackageIndexStrategy {
      return false
    }

    if let varDecl = node.as(VariableDeclSyntax.self),
      let patternBinding = varDecl.bindings.first,
      patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "package"
    {
      return true
    }
    return false
  }

  internal func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
    switch (currentState, node.item) {
    case (.modifier(let index), .expr):
      assert(self.modifiers[index] != nil)
      self.modifiers[index]?.append(node.item.trimmedDescription)
    case (.root, _):
      if node.parent?.parent?.is(SourceFileSyntax.self) == true {
        return .visitChildren
      }
    case (.labeledExpr(let kind), .expr):
      currentState = .codeBlockFor(kind)
      return .visitChildren
    default:
      break
    }
    return .skipChildren
  }

  internal func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
    guard let patternBinding = node.bindings.first,
      patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "package"
    else {
      return .skipChildren
    }
    currentState = .variable
    return .visitChildren
  }

  internal func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
    if node.calledExpression.is(MemberAccessExprSyntax.self)
      || node.calledExpression.is(DeclReferenceExprSyntax.self)
    {
      return .visitChildren
    }
    return .skipChildren
  }

  internal func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
    switch (currentState, node.baseName.identifier?.name) {
    case (.functionCall, "Package"):
      return .visitChildren
    case (.codeBlockFor(let expressionKind), .some(let name)):
      items.append((expressionKind, name))
      currentState = .labeledExpr(expressionKind)
      return .visitChildren
    case (_, .some(let name)):
      if let modifier = ModifierType(rawValue: name) {
        modifiers[modifier] = []
        self.currentState = .modifier(modifier)
        return .visitChildren
      }
    default:
      break
    }
    return .skipChildren
  }

  // add visit ClosureExpression
  internal func visit(_ node: LabeledExprSyntax) -> SyntaxVisitorContinueKind {
    guard currentState == .variable,
      let name = node.label?.identifier?.name,
      let expressionType = ExpressionKind(rawValue: name)
    else {
      return .skipChildren
    }
    currentState = .labeledExpr(expressionType)
    return .visitChildren
  }

  internal func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    .skipChildren
  }

  internal func visitPost(_ node: LabeledExprSyntax) {
    if case .modifier(let modifier) = currentState, !node.trimmedDescription.isEmpty {
      assert(self.modifiers[modifier] != nil)
      self.modifiers[modifier]?.append(node.trimmedDescription)
    }
    guard case .labeledExpr(let stateExpressionType) = currentState else {
      return
    }
    guard let name = node.label?.identifier?.name else {
      return
    }
    guard let expressionType = ExpressionKind(rawValue: name) else {
      return
    }
    if stateExpressionType == expressionType {
      self.currentState = .variable
    }
  }
}
