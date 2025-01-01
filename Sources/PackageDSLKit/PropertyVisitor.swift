//
//  PropertyVisitor.swift
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

class PropertyVisitor: SyntaxVisitor {
  var name: String?
  var type: String?
  var code: [String] = []

  func parse(_ node: VariableDeclSyntax) throws -> Property {
    self.walk(node)
    return try Property(name: name, type: type, code: code)
  }

  override func visit(_ node: CodeBlockItemSyntax) -> SyntaxVisitorContinueKind {
    self.code.append(node.trimmedDescription)
    return .skipChildren
  }

  override func visit(_ node: IdentifierPatternSyntax) -> SyntaxVisitorContinueKind {
    self.name = node.identifier.text
    return .skipChildren
  }

  override func visit(_ node: TypeAnnotationSyntax) -> SyntaxVisitorContinueKind {
    self.type = node.trimmedDescription
    return .skipChildren
  }

  override func visit(_ node: MemberTypeSyntax) -> SyntaxVisitorContinueKind {
    self.type = node.trimmedDescription
    return .skipChildren
  }

  override func visit(_ node: SomeOrAnyTypeSyntax) -> SyntaxVisitorContinueKind {
    self.type = node.trimmedDescription
    return .skipChildren
  }
}
