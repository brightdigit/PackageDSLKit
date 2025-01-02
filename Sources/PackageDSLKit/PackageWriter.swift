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
import SwiftSyntaxBuilder

public struct PropertyWriter {
  func node(from property: Property) -> VariableDeclSyntax {
    let codeBlocks = property.code.map(CodeBlockItemSyntax.init)
    let codeBlockList = CodeBlockItemListSyntax(codeBlocks)
    // swiftlint:disable:next force_try
    return try! VariableDeclSyntax(
      """
        var \(raw: property.name): \(raw: property.type) {
          \(codeBlockList)
        }
      """
    )
  }
}

public struct ComponentWriter {
  let propertyWriter = PropertyWriter()
  func node(from component: Component) -> StructDeclSyntax {
    let memberBlockList = MemberBlockItemListSyntax(
      component.properties.values.map(propertyWriter.node(from:)).map {
        MemberBlockItemSyntax(decl: $0)
      }
    )
    let inheritedTypes = component.inheritedTypes.map { TokenSyntax.identifier($0) }.map {
      IdentifierTypeSyntax(name: $0)
    }.map {
      InheritedTypeSyntax(type: $0)
    }.reversed().enumerated().map { index, expression in
      if index == 0 {
        return expression
      }
      return expression.with(\.trailingComma, .commaToken())
    }.reversed()
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

public struct PackageIndexWriter {
  public func labeledExpression(for name: String, items: [String]) -> LabeledExprSyntax? {
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

  public func writeIndex(_ index: Index) throws -> String {
    let declSyntax: DeclSyntax = .init(ImportDeclSyntax.module("PackageDescription"))

    let labeledExpressions = [
      self.labeledExpression(for: "entries", items: index.entries.map(\.name)),
      self.labeledExpression(for: "dependencies", items: index.dependencies.map(\.name)),
      self.labeledExpression(for: "testTargets", items: index.testTargets.map(\.name)),
      self.labeledExpression(for: "swiftSettings", items: index.swiftSettings.map(\.name)),
    ].compactMap { $0 }.reversed().enumerated().map { index, expression in
      if index == 0 {
        return expression
      }
      return expression.with(\.trailingComma, .commaToken())
    }.reversed()
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
}

public struct PackageWriter {
  public init() {
  }

  let fileManager: FileManager = .default
  let indexWriter: PackageIndexWriter = .init()
  let componentWriter: ComponentWriter = .init()
  static let compoenentTypes: [any ComponentBuildable.Type] = [
    Product.self,
    Dependency.self,
    TestTarget.self,
    SupportedPlatformSet.self,
  ]
  public func write(_ specification: PackageSpecifications, to url: URL) throws(PackageDSLError) {
    let configuration = PackageDirectoryConfiguration(specifications: specification)

    let indexFileURL = url.appending(component: "Index.swift")
    do {
      try indexWriter.writeIndex(configuration.index).write(
        to: indexFileURL, atomically: true, encoding: .utf8)
    } catch {
      throw .other(error)
    }
    let components = configuration.createComponents()
    var directoryCreated = [URL: Void]()

    for component in components {
      let directoryURL: URL
      let componentType = Self.compoenentTypes.first(where: { component.isType(of: $0) })
      guard let componentType else {
        throw .custom("Unsupported component", component)
      }

      directoryURL = componentType.directoryURL(relativeTo: url)

      if directoryCreated[directoryURL] == nil {
        do {
          try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        } catch {
          throw .other(error)
        }
        directoryCreated[directoryURL] = ()
      }

      let filePath =
        directoryURL
        .appending(path: component.name)
        .appendingPathExtension("swift")
        .standardizedFileURL

      let node = componentWriter.node(from: component)
      do {
        try node.description.write(to: filePath, atomically: true, encoding: .utf8)
      } catch {
        throw .other(error)
      }
    }
  }
}
