//
//  ProcessRunner.swift
//  SyntaxKit
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
  public enum ProcessRunner {
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
    ) async throws -> ProcessResult {
      try await withCheckedThrowingContinuation { continuation in
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [executable] + arguments

        if let workingDirectory = workingDirectory {
          process.currentDirectoryURL = workingDirectory
        }

        if let environment = environment {
          process.environment = environment
        }

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // Set up timeout
        let timeoutTask = Task {
          try await Task.sleep(for: .seconds(timeout))
          if process.isRunning {
            process.terminate()
            continuation.resume(throwing: ProcessRunnerError.timeout)
          }
        }

        process.terminationHandler = { process in
          timeoutTask.cancel()

          let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
          let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

          let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
          let stderr = String(data: stderrData, encoding: .utf8) ?? ""

          let result = ProcessResult(
            processIdentifier: process.processIdentifier,
            exitCode: process.terminationStatus,
            standardOutput: stdout,
            standardError: stderr
          )

          // Check for non-zero exit codes if needed
          if !result.isSuccess && result.exitCode != 0 {
            continuation.resume(
              throwing: ProcessRunnerError.nonZeroExit(result.exitCode, result.standardError))
          } else {
            continuation.resume(returning: result)
          }
        }

        do {
          try process.run()
        } catch {
          timeoutTask.cancel()
          continuation.resume(
            throwing: ProcessRunnerError.executionFailed(error.localizedDescription))
        }
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
    ) async throws -> ProcessResult {
      try await execute(
        "swift",
        arguments: arguments,
        workingDirectory: workingDirectory,
        timeout: timeout
      )
    }
  }
#endif
