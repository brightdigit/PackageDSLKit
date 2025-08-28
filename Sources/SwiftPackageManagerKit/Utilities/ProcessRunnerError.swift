//
//  ProcessRunnerError.swift
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

/// Error types for ProcessRunner
/// **Note:** This utility is only available on macOS and Linux platforms.
/// It is not available on iOS, watchOS, tvOS, or visionOS due to platform limitations.

public enum ProcessRunnerError: Error, LocalizedError, Sendable {
  case timeout
  case executionFailed(String)
  case nonZeroExit(Int32, String)

  public var errorDescription: String? {
    switch self {
    case .timeout:
      return "Process execution timed out"
    case .executionFailed(let message):
      return "Process execution failed: \(message)"
    case .nonZeroExit(let code, let stderr):
      return "Process exited with code \(code): \(stderr)"
    }
  }
}
