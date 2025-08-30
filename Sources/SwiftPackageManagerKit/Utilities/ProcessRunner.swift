//
//  ProcessRunner.swift
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

/// Async process runner using swift-subprocess
/// **Note:** This utility is only available on macOS and Linux platforms.
/// It is not available on iOS, watchOS, tvOS, or visionOS due to platform limitations.
#if canImport(Foundation) && (os(macOS) || os(Linux))
  public import Foundation

  /// A utility for running processes asynchronously with timeout and error handling.
  ///
  /// This enum provides static methods for executing external processes with proper
  /// resource management, timeout handling, and result processing. It's designed to
  /// work with the swift-subprocess library for cross-platform process execution.
  public enum ProcessRunner {
    // MARK: - Private Helper Functions

    /// Handles process termination and executes the completion closure
    /// - Parameters:
    ///   - process: The Process instance
    ///   - stdoutPipe: The stdout pipe
    ///   - stderrPipe: The stderr pipe
    ///   - timeoutTask: The timeout task to cancel
    ///   - completed: Closure to execute with the result (success or failure)
    private static func handleProcessTermination(
      process: Process,
      stdoutPipe: Pipe,
      stderrPipe: Pipe,
      timeoutTask: Task<Void, Never>,
      completed: @Sendable @escaping (Result<ProcessResult, ProcessRunnerError>) -> Void
    ) {
      timeoutTask.cancel()

      let result = process.createProcessResult(from: stdoutPipe, stderrPipe: stderrPipe)

      // Check for non-zero exit codes if needed
      if !result.isSuccess && result.exitCode != 0 {
        completed(.failure(ProcessRunnerError.nonZeroExit(result.exitCode, result.standardError)))
      } else {
        completed(.success(result))
      }
    }

    /// Sets up the termination handler for the process
    /// - Parameters:
    ///   - process: The Process instance
    ///   - stdoutPipe: The stdout pipe
    ///   - stderrPipe: The stderr pipe
    ///   - timeoutTask: The timeout task
    ///   - completed: Closure to execute with the result (success or failure)
    private static func setupTerminationHandler(
      for process: Process,
      stdoutPipe: Pipe,
      stderrPipe: Pipe,
      timeoutTask: Task<Void, Never>,
      completed: @Sendable @escaping (Result<ProcessResult, ProcessRunnerError>) -> Void
    ) {
      process.terminationHandler = { process in
        handleProcessTermination(
          process: process,
          stdoutPipe: stdoutPipe,
          stderrPipe: stderrPipe,
          timeoutTask: timeoutTask,
          completed: completed
        )
      }
    }

    /// Handles the continuation logic for process execution
    /// - Parameters:
    ///   - executable: The executable name or path
    ///   - arguments: Command line arguments
    ///   - workingDirectory: Working directory for the process
    ///   - environment: Environment variables
    ///   - timeout: Timeout duration in seconds
    ///   - completed: Closure to execute with the result (success or failure)
    private static func handleProcessExecution(
      executable: String,
      arguments: [String],
      workingDirectory: URL?,
      environment: [String: String]?,
      timeout: TimeInterval,
      completed: @Sendable @escaping (Result<ProcessResult, ProcessRunnerError>) -> Void
    ) {
      let process = Process(
        executable: executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
        environment: environment
      )

      let (stdoutPipe, stderrPipe) = process.setupPipes()
      let timeoutTask = process.createTimeoutTask(timeout: timeout) {
        completed(.failure(ProcessRunnerError.timeout))
      }

      setupTerminationHandler(
        for: process,
        stdoutPipe: stdoutPipe,
        stderrPipe: stderrPipe,
        timeoutTask: timeoutTask,
        completed: completed
      )

      do {
        try process.run()
      } catch {
        timeoutTask.cancel()
        completed(.failure(ProcessRunnerError.executionFailed(error.localizedDescription)))
      }
    }

    // MARK: - Public API

    /// Execute a command with arguments
    /// - Parameters:
    ///   - executable: The executable name or path
    ///   - arguments: Command line arguments
    ///   - workingDirectory: Working directory for the process
    ///   - environment: Environment variables (nil uses inherited environment)
    ///   - timeout: Timeout in seconds (default: 30)
    /// - Returns: ProcessResult containing output and status
    /// - Throws: ProcessRunnerError on failure
    public static func execute(
      _ executable: String,
      arguments: [String] = [],
      workingDirectory: URL? = nil,
      environment: [String: String]? = nil,
      timeout: TimeInterval = 30
    ) async throws(ProcessRunnerError) -> ProcessResult {
      do {
        return try await withCheckedThrowingContinuation { continuation in
          handleProcessExecution(
            executable: executable,
            arguments: arguments,
            workingDirectory: workingDirectory,
            environment: environment,
            timeout: timeout,
            completed: {
              continuation.resume(with: $0)
            }
          )
        }
      } catch let processRunnerError as ProcessRunnerError {
        throw processRunnerError
      } catch {
        assertionFailure("This error should never happen: \(error.localizedDescription)")
        throw ProcessRunnerError.unknownError(error)
      }
    }

    /// Convenience method to execute a command and return just the output
    /// - Parameters:
    ///   - executable: The executable name or path
    ///   - arguments: Command line arguments
    ///   - workingDirectory: Working directory for the process
    ///   - timeout: Timeout in seconds (default: 30)
    /// - Returns: Standard output as string
    /// - Throws: ProcessRunnerError on failure
    public static func output(
      _ executable: String,
      arguments: [String] = [],
      workingDirectory: URL? = nil,
      timeout: TimeInterval = 30
    ) async throws -> String {
      let result = try await execute(
        executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
        timeout: timeout
      )
      return result.standardOutput
    }

    /// Execute a swift command with arguments
    /// - Parameters:
    ///   - arguments: Swift command arguments (e.g., ["package", "dump-package"])
    ///   - workingDirectory: Working directory for the process
    ///   - timeout: Timeout in seconds (default: 30)
    /// - Returns: ProcessResult containing output and status
    /// - Throws: ProcessRunnerError on failure
    public static func swift(
      arguments: [String],
      workingDirectory: URL? = nil,
      timeout: TimeInterval = 30
    ) async throws(ProcessRunnerError) -> ProcessResult {
      try await execute(
        "swift",
        arguments: arguments,
        workingDirectory: workingDirectory,
        timeout: timeout
      )
    }
  }
#endif
