//
//  PackageIndexWriter.swift
//  MistKit
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

import SyntaxKit

/// A writer that generates Package.swift index code using SyntaxKit
///
/// This struct implements the IndexCodeWriter protocol to generate Swift code
/// for package indices, delegating the actual code generation to SyntaxKit.
public struct PackageIndexWriter: IndexCodeWriter, Sendable, Hashable, Codable {
  /// Creates a new package index writer
  public init() {
  }
  /// Writes an index to Swift code string
  ///
  /// - Parameter index: The index to convert to Swift code
  ///
  /// - Returns: A Swift code string representing the index
  /// - Throws: `PackageDSLError` if code generation fails
  public func writeIndex(_ index: Index) throws(PackageDSLError) -> String {
    try syntaxKitWriteIndex(index)
  }

  /// Creates index using SyntaxKit
  public func syntaxKitWriteIndex(_ index: Index) throws(PackageDSLError) -> String {
    // Create import declaration
    let importDecl = Import("PackageDescription")

    // Helper function to create parameter for each section
    func createParameter(name: String, items: [String]) -> ParameterExp? {
      guard !items.isEmpty else {
        return nil
      }

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
      createParameter(name: "swiftSettings", items: index.swiftSettings.map(\.name)),
    ].compactMap { $0 }

    // Create Package initialization
    // For simplicity, use the first few parameters
    let packageInit = Init("Package", params: Array(parameters.prefix(4)))

    // Create let package = Package(...) variable
    let packageVar = Variable(.let, name: "package", equals: packageInit)

    // Combine import and package declaration
    let codeBlocks: [CodeBlock] = [importDecl, packageVar]

    // Convert to syntax using SyntaxKit's code generation
    let lines = codeBlocks.map { codeBlock in
      codeBlock.trimmedDescription
    }

    return lines.joined(separator: "\n")
  }
}
