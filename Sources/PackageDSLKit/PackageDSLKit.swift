//
//  PackageDSLKit.swift
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

////
////  PackageDSLKit.swift
////  PackageDSLKit
////
////  Created by Leo Dion.
////  Copyright © 2024 BrightDigit.
////
////  Permission is hereby granted, free of charge, to any person
////  obtaining a copy of this software and associated documentation
////  files (the “Software”), to deal in the Software without
////  restriction, including without limitation the rights to use,
////  copy, modify, merge, publish, distribute, sublicense, and/or
////  sell copies of the Software, and to permit persons to whom the
////  Software is furnished to do so, subject to the following
////  conditions:
////
////  The above copyright notice and this permission notice shall be
////  included in all copies or substantial portions of the Software.
////
////  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
////  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
////  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
////  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
////  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
////  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
////  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
////  OTHER DEALINGS IN THE SOFTWARE.
////
//
// import SwiftSyntax
// import SwiftParser
// import Foundation
// import os
//
//
//
//
//
//
//
//
//// class PackageCallRewriter : SyntaxRewriter {
//////  override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
//////  }
//// }
////
//// class PackageFileRewriter : SyntaxRewriter {
////  internal init(packageCallRewriter: SyntaxRewriter = PackageCallRewriter()) {
////    self.packageCallRewriter = packageCallRewriter
////  }
////
////  let packageCallRewriter: SyntaxRewriter
////
//////  override func visit(_ node: SourceFileSyntax) -> SourceFileSyntax {
//////
//////  }
//// }
//
// @available(*, deprecated)
// public enum PackageDSLKit {
//
//  @available(*, deprecated)
//  public  static func parse(_ directoryURL: URL, with fileManager: FileManager) throws {
//    let indexFileURL = directoryURL.appendingPathComponent("Index.swift")
//    guard fileManager.fileExists(atPath: indexFileURL.path) else {
//      throw PackageDSLError.custom("Could not find Index.swift file at \(indexFileURL)", indexFileURL)
//    }
//    let sourceCode = try String(contentsOf: indexFileURL)
//
//    let sourceSyntax = Parser.parse(source: sourceCode)
//    //PackageRewriter(viewMode: .fixedUp).visit(sourceSyntax)
//
//    let packageVisitor = PackageIndexVisitor(viewMode: .fixedUp)
//    packageVisitor.walk(sourceSyntax)
//    dump(packageVisitor.items)
//    let packageStatement = sourceSyntax.statements.first { syntax in
//      guard case let .decl( declaration) = syntax.item else {
//        return false
//      }
//
//      guard let patternBinding = declaration.as(VariableDeclSyntax.self)?.bindings.first else {
//        return false
//      }
//      guard patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "package" else {
//        return false
//      }
//      guard let packageInitValue = patternBinding.initializer?.value else {
//        return false
//      }
//      //dump(packageInitValue)
//      guard let calledExpression = packageInitValue
//        .as(FunctionCallExprSyntax.self)?
//        .calledExpression
//        .as(MemberAccessExprSyntax.self)?
//        .base?
//        .as(FunctionCallExprSyntax.self)?
//        .calledExpression
//      else {
//        return false
//      }
//      guard let functionCall = calledExpression
//        .cast(MemberAccessExprSyntax.self)
//        .base?
//        .cast(FunctionCallExprSyntax.self)
//        else {
//        return false
//      }
//      guard let identifier = functionCall
//        .calledExpression
//        .cast(DeclReferenceExprSyntax.self)
//        .baseName
//        .identifier else {
//        return false
//      }
//      guard identifier.name == "Package" else {
//        return false
//      }
//      return true
//    }
//    guard let packageStatement else {
//      return
//    }
//  }
//

//
// }
