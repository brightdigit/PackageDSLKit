//
//  PackageVisitor.swift
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

internal class PackageVisitor: SyntaxVisitor {
  private var currentStrategy: ParsingStrategy?
  private let availableStrategies: [ParsingStrategy]

  private var results: [ParsingResult] = []
  #if canImport(os)
    private let logger = Logger(subsystem: "packagedsl", category: "structure")
  #elseif canImport(Logging)
    private let logger = Logger(label: "structure")
  #endif

  internal init(
    viewMode: SyntaxTreeViewMode = .fixedUp,
    strategies: [ParsingStrategy] = [PackageIndexStrategy(), StructureStrategy()]
  ) {
    self.availableStrategies = strategies
    self.currentStrategy = nil
    super.init(viewMode: viewMode)
  }

  internal func parse(_ node: some SyntaxProtocol) -> [ParsingResult] {
    super.walk(node)
    self.finishCurrentStrategy()
    return results
  }
  fileprivate func finishCurrentStrategy() {
    if let current = currentStrategy {
      // Store result from current strategy before switching
      guard let result = current.finalize() else {
        return
      }
      results.append(result)
      current.reset()
    }
  }

  private func checkForStrategyActivation(_ node: some SyntaxProtocol) {
    if let newStrategy = availableStrategies.first(where: {
      $0.shouldActivate(node, currentStrategy: currentStrategy)
    }) {
      finishCurrentStrategy()
      currentStrategy = newStrategy
    }
  }

  override internal func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
    checkForStrategyActivation(node)
    return currentStrategy?.visit(node) ?? .visitChildren
  }

  override internal func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
    checkForStrategyActivation(node)
    return currentStrategy?.visit(node) ?? .visitChildren
  }

  override internal func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
    currentStrategy?.visit(node) ?? .visitChildren
  }

  override internal func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
    currentStrategy?.visit(node) ?? .visitChildren
  }

  override internal func visit(_ node: LabeledExprSyntax) -> SyntaxVisitorContinueKind {
    currentStrategy?.visit(node) ?? .visitChildren
  }

  override internal func visitPost(_ node: LabeledExprSyntax) {
    currentStrategy?.visitPost(node)
  }

  override internal func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    checkForStrategyActivation(node)
    return currentStrategy?.visit(node) ?? .visitChildren
  }

  override internal func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
    currentStrategy?.visit(node) ?? .visitChildren
  }
}
