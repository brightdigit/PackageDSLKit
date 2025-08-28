//
//  PropertyWriter.swift
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

public import SyntaxKit

public enum PropertyWriter: Sendable {
  /// Creates a property variable using SyntaxKit
  public static func syntaxKitNode(from property: Property) -> ComputedProperty {
    // Convert string code blocks to SyntaxKit CodeBlocks
    let codeBlocks: [CodeBlock] = property.code.map { Literal.ref($0) }

    // Create a computed property with the code blocks as body
    // For now, we'll just use the first code block or create an empty return
    if let firstCodeBlock = codeBlocks.first {
      return ComputedProperty(property.name, type: property.type) {
        firstCodeBlock
      }
    } else {
      return ComputedProperty(property.name, type: property.type) {
        // Empty computed property body
      }
    }
  }
}
