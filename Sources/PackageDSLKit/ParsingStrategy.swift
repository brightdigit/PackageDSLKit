//
//  ParsingStrategy.swift
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

// Protocol for different parsing strategies
internal protocol ParsingStrategy {
  // Return true if this strategy should handle the current context
  func shouldActivate(_ node: some SyntaxProtocol, currentStrategy: ParsingStrategy?) -> Bool

  // Called when switching from this strategy to another
  func finalize() -> ParsingResult?

  // Reset the strategy's state
  func reset()

  func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind
  func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind
  func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind
  func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind
  func visit(_ node: LabeledExprSyntax) -> SyntaxVisitorContinueKind
  func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind
  func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind
  func visitPost(_ node: LabeledExprSyntax)
}

// Default implementations
extension ParsingStrategy {
  internal func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
    .visitChildren
  }

  internal func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
    .visitChildren
  }

  internal func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
    .visitChildren
  }

  internal func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
    .visitChildren
  }

  internal func visit(_ node: LabeledExprSyntax) -> SyntaxVisitorContinueKind {
    .visitChildren
  }

  internal func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    .visitChildren
  }

  internal func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
    .visitChildren
  }

  internal func visitPost(_ node: LabeledExprSyntax) {}

  internal func reset() {}
}
