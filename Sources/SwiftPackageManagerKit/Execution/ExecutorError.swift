//
//  ExecutorError.swift
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

/// SPM command execution errors
public enum ExecutorError: Error, LocalizedError, Sendable {
  case invalidPackagePath
  case swiftNotFound
  case packageNotFound
  case invalidJSON(String)
  case commandFailed(String, String)  // command, error message

  /// A localized description of the error.
  ///
  /// This property provides a human-readable description of the executor error,
  /// including specific details about what went wrong during command execution.
  public var errorDescription: String? {
    switch self {
    case .invalidPackagePath:
      return "Invalid package path provided"
    case .swiftNotFound:
      return "Swift executable not found in PATH"
    case .packageNotFound:
      return "Package.swift not found in the specified directory"
    case .invalidJSON(let error):
      return "Invalid JSON response from swift package dump-package: \(error)"
    case .commandFailed(let command, let error):
      return "Swift command '\(command)' failed: \(error)"
    }
  }
}
