//
//  Process+Extensions.swift
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

#if canImport(Foundation) && (os(macOS) || os(Linux))
  import Foundation

  extension Process {
    /// Creates and configures a Process instance with the given parameters
    /// - Parameters:
    ///   - executable: The executable name or path
    ///   - arguments: Command line arguments (default: empty array)
    ///   - workingDirectory: Working directory for the process (default: nil)
    ///   - environment: Environment variables (default: nil)
    convenience init(
      executable: String,
      arguments: [String] = [],
      workingDirectory: URL? = nil,
      environment: [String: String]? = nil
    ) {
      self.init()
      executableURL = URL(fileURLWithPath: "/usr/bin/env")
      self.arguments = [executable] + arguments

      if let workingDirectory = workingDirectory {
        currentDirectoryURL = workingDirectory
      }

      if let environment = environment {
        self.environment = environment
      }
    }

    /// Sets up pipes for stdout and stderr
    /// - Returns: Tuple containing stdout and stderr pipes
    func setupPipes() -> (stdout: Pipe, stderr: Pipe) {
      let stdoutPipe = Pipe()
      let stderrPipe = Pipe()
      standardOutput = stdoutPipe
      standardError = stderrPipe
      return (stdoutPipe, stderrPipe)
    }

    /// Creates a timeout task that terminates the process if it exceeds the timeout
    /// - Parameters:
    ///   - timeout: Timeout duration in seconds
    ///   - onTimeout: Closure to execute when timeout occurs
    /// - Returns: The timeout task for cancellation
    func createTimeoutTask(
      timeout: TimeInterval,
      onTimeout: @Sendable @escaping () -> Void
    ) -> Task<Void, Never> {
      Task {
        do {
          try await Task.sleep(for: .seconds(timeout))
        } catch {
          print(error)
        }

        if isRunning {
          terminate()
          onTimeout()
        }
      }
    }

    /// Reads data from pipes and creates a ProcessResult
    /// - Parameters:
    ///   - stdoutPipe: The stdout pipe
    ///   - stderrPipe: The stderr pipe
    /// - Returns: ProcessResult with output and status
    func createProcessResult(
      from stdoutPipe: Pipe,
      stderrPipe: Pipe
    ) -> ProcessResult {
      let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
      let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

      let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
      let stderr = String(data: stderrData, encoding: .utf8) ?? ""

      return ProcessResult(
        processIdentifier: processIdentifier,
        exitCode: terminationStatus,
        standardOutput: stdout,
        standardError: stderr
      )
    }
  }
#endif
