//
//  Executor+Example.swift
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

/// Example usage of the closure-based Executor
extension Executor {
  /// Example: Create an Executor with a custom Swift command executor
  /// This is useful for testing, mocking, or custom process execution logic
  public static func withCustomExecutor(
    packageDirectory: URL,
    defaultTimeout: TimeInterval = 60,
    customExecutor: @escaping SwiftCommandExecutor
  ) throws -> Executor {
    try Executor(
      packageDirectory: packageDirectory,
      defaultTimeout: defaultTimeout,
      swiftExecutor: customExecutor
    )
  }

  /// Example: Create an Executor that logs all Swift commands before execution
  //  public static func withLogging(
  //    packageDirectory: URL,
  //    defaultTimeout: TimeInterval = 60
  //  ) throws -> Executor {
  //    let loggingExecutor: SwiftCommandExecutor = { arguments, workingDirectory, timeout in
  //      print("🔄 Executing: swift \(arguments.joined(separator: " "))")
  //      print("   Working directory: \(workingDirectory?.path ?? "current")")
  //      print("   Timeout: \(timeout)s")
  //
  //      // Delegate to the default ProcessRunner.swift
  //      return try await ProcessRunner.swift(
  //        arguments: arguments,
  //        workingDirectory: workingDirectory,
  //        timeout: timeout
  //      )
  //    }
  //
  //    return try Executor(
  //      packageDirectory: packageDirectory,
  //      defaultTimeout: defaultTimeout,
  //      swiftExecutor: loggingExecutor
  //    )
  //  }

  /// Example: Create an Executor that simulates Swift commands for testing
  public static func withSimulatedExecutor(
    packageDirectory: URL,
    defaultTimeout: TimeInterval = 60,
    simulatedOutput: String = "Simulated output",
    simulatedExitCode: Int32 = 0
  ) throws -> Executor {
    let simulatedExecutor: SwiftCommandExecutor = { _, _, _ in
      // Simulate a delay to mimic real execution
      if #available(iOS 16.0, watchOS 9.0, tvOS 16.0, macOS 13.0, *) {
        try await Task.sleep(for: .milliseconds(100))
      } else {
        try await Task.sleep(100 * 100)
      }

      // Return simulated result
      return ProcessResult(
        processIdentifier: 12_345,
        exitCode: simulatedExitCode,
        standardOutput: simulatedOutput,
        standardError: ""
      )
    }

    return try Executor(
      packageDirectory: packageDirectory,
      defaultTimeout: defaultTimeout,
      swiftExecutor: simulatedExecutor
    )
  }
}
