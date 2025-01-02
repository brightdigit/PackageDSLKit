//
//  PackageParser.swift
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
import SwiftParser

public struct PackageParser {
  public init() {
  }
  private func parseResults(at directoryURL: URL, with fileManager: FileManager)
    throws(PackageDSLError)
    -> [ParsingResult]
  {
    guard let enumerator = fileManager.enumerator(atPath: directoryURL.standardizedFileURL.path())
    else {
      throw .custom("Missing Enumerator at \(directoryURL)", nil)
    }
    var results = [ParsingResult]()
    while let filePath = enumerator.nextObject() as? String {
      guard filePath.hasSuffix(".swift") else {
        continue
      }
      let sourceCode: String
      do {
        sourceCode = try String(contentsOf: directoryURL.appending(path: filePath))
      } catch {
        throw .other(error)
      }
      let sourceSyntax = Parser.parse(source: sourceCode)
      let packageVisitor = PackageVisitor()
      results.append(contentsOf: packageVisitor.parse(sourceSyntax))
    }
    return results
  }
  public func parse(at directoryURL: URL, with fileManager: FileManager) throws(PackageDSLError)
    -> PackageSpecifications
  {
    let results = try parseResults(at: directoryURL, with: fileManager)

    let directoryConfiguration = try PackageDirectoryConfiguration(from: results)

    return try .init(from: directoryConfiguration)
  }
}
