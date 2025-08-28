//
//  PackageError.swift
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

public import Foundation

/// Errors that can occur during package manipulation
public enum PackageError: Error, LocalizedError, Sendable {
  case duplicateTargetName(String)
  case duplicateProductName(String)
  case duplicateDependencyName(String)
  case targetNotFound(String)
  case productNotFound(String)
  case dependencyNotFound(String)
  case invalidConfiguration(String)
  // case validationFailed([ValidationIssue])
  case packageGenerationFailed(String)
  case cascadeRemovalRequired(String, [String])

  public var errorDescription: String? {
    switch self {
    case .duplicateTargetName(let name):
      return "Target name '\(name)' already exists"
    case .duplicateProductName(let name):
      return "Product name '\(name)' already exists"
    case .duplicateDependencyName(let name):
      return "Dependency name '\(name)' already exists"
    case .targetNotFound(let name):
      return "Target '\(name)' not found"
    case .productNotFound(let name):
      return "Product '\(name)' not found"
    case .dependencyNotFound(let name):
      return "Dependency '\(name)' not found"
    case .invalidConfiguration(let message):
      return "Invalid configuration: \(message)"
    //    case .validationFailed(let issues):
    //      let errorCount = issues.filter { $0.severity == .error }.count
    //      return "Package validation failed with \(errorCount) error\(errorCount == 1 ? "" : "s")"
    case .packageGenerationFailed(let message):
      return "Failed to generate Package.swift: \(message)"
    case .cascadeRemovalRequired(let item, let dependents):
      return "Cannot remove '\(item)' because it is used by: \(dependents.joined(separator: ", "))"
    }
  }
}
