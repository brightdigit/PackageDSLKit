//
//  ProcessResult.swift
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

/// Result of a process execution
/// **Note:** This utility is only available on macOS and Linux platforms.
/// It is not available on iOS, watchOS, tvOS, or visionOS due to platform limitations.

/// Represents the result of a completed process execution.
///
/// This struct contains information about a process that has finished running,
/// including its exit code, output streams, and process identifier.
public struct ProcessResult: Sendable {
  /// The process identifier
  public let processIdentifier: Int32

  /// The termination status of the process (exit code)
  public let exitCode: Int32

  /// Standard output as a string
  public let standardOutput: String

  /// Standard error as a string
  public let standardError: String

  /// Whether the process succeeded (exit code 0)
  public var isSuccess: Bool {
    exitCode == 0
  }

  /// Creates a new ProcessResult instance with the specified process information.
  ///
  /// - Parameters:
  ///   - processIdentifier: The process identifier (PID).
  ///   - exitCode: The termination status/exit code of the process.
  ///   - standardOutput: The standard output captured from the process.
  ///   - standardError: The standard error captured from the process.
  public init(
    processIdentifier: Int32,
    exitCode: Int32,
    standardOutput: String,
    standardError: String
  ) {
    self.processIdentifier = processIdentifier
    self.exitCode = exitCode
    self.standardOutput = standardOutput
    self.standardError = standardError
  }
}
