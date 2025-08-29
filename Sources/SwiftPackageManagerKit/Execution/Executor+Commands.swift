//
//  Executor+Commands.swift
//  MistKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

public import Foundation

// MARK: - SPM Command Methods
extension Executor {
  /// Execute `swift package dump-package` and return parsed package info
  /// - Parameter timeout: Optional timeout override
  /// - Returns: Parsed PackageInfo
  /// - Throws: ExecutorError on failure
  public func dumpPackage(timeout: TimeInterval? = nil) async throws(ExecutorError) -> PackageInfo {
    let actualTimeout = timeout ?? defaultTimeout
    let result : ProcessResult
    do {
       result = try await swiftExecutor(
        ["package", "dump-package"],
        packageDirectory,
        actualTimeout
      )
    } catch let error  {
      throw handleProcessRunnerError(error, command: "package dump-package", timeout: actualTimeout)
    }
    
    do {
      

      return try parsePackageInfo(from: result.standardOutput)
    } catch let error as ExecutorError {
      throw error
    }
  }

  private func parsePackageInfo(from output: String) throws(ExecutorError) -> PackageInfo {
    print(output)
    guard let jsonData = output.data(using: .utf8) else {
      throw ExecutorError.invalidJSON("Could not convert output to UTF-8 data")
    }

    let decoder = JSONDecoder()
    do {
      return try decoder.decode(PackageInfo.self, from: jsonData)
    } catch {
      dump(error)
      throw ExecutorError.invalidJSON(error.localizedDescription)
    }
  }

  /// Execute `swift package resolve` to resolve dependencies
  /// - Parameter timeout: Optional timeout override
  /// - Throws: ExecutorError on failure
  public func resolvePackage(timeout: TimeInterval? = nil) async throws(ExecutorError) {

    let actualTimeout = timeout ?? defaultTimeout
    do {
      _ = try await swiftExecutor(
        ["package", "resolve"],
        packageDirectory,
        actualTimeout
      )
    } catch {
      throw handleProcessRunnerError(error, command: "package resolve", timeout: actualTimeout)
    }
  }

  /// Execute `swift build` to build the package
  /// - Parameters:
  ///   - target: Optional specific target to build
  ///   - configuration: Build configuration (.debug or .release)
  ///   - timeout: Optional timeout override
  /// - Throws: ExecutorError on failure
  public func buildPackage(
    target: String? = nil,
    configuration: BuildConfiguration = .debug,
    timeout: TimeInterval? = nil
  ) async throws(ExecutorError) {
    let actualTimeout = timeout ?? defaultTimeout
    let arguments = buildArguments(for: configuration, target: target)

    do {
      _ = try await swiftExecutor(
        arguments,
        packageDirectory,
        actualTimeout
      )
    } catch let error {
      let command = "build" + (target.map { " --target \($0)" } ?? "")
      throw handleProcessRunnerError(error, command: command, timeout: actualTimeout)
    }
  }

  private func buildArguments(for configuration: BuildConfiguration, target: String?) -> [String] {
    var arguments = ["build"]

    // Add configuration
    switch configuration {
    case .debug:
      arguments.append("--configuration")
      arguments.append("debug")
    case .release:
      arguments.append("--configuration")
      arguments.append("release")
    }

    // Add target if specified
    if let target = target {
      arguments.append("--target")
      arguments.append(target)
    }

    return arguments
  }

  private func handleProcessRunnerError(
    _ error: ProcessRunnerError,
    command: String,
    timeout: TimeInterval
  ) -> ExecutorError {
    switch error {
    case .timeout:
      return ExecutorError.commandFailed(
        command, "Command timed out after \(timeout) seconds"
      )
    case .nonZeroExit(let code, let stderr):
      return ExecutorError.commandFailed(command, "Exit code \(code): \(stderr)")
    case .executionFailed(let message):
      return ExecutorError.commandFailed(command, message)
    case .unknownError(let error):
      return ExecutorError.commandFailed(command, error.localizedDescription)
    }
  }

  /// Execute `swift test` to run package tests
  /// - Parameters:
  ///   - target: Optional specific test target to run
  ///   - timeout: Optional timeout override
  /// - Throws: ExecutorError on failure
  public func testPackage(
    target: String? = nil,
    timeout: TimeInterval? = nil
  ) async throws(ExecutorError) {
    let actualTimeout = timeout ?? defaultTimeout
    let arguments = testArguments(for: target)

    do {
      _ = try await swiftExecutor(
        arguments,
        packageDirectory,
        actualTimeout
      )
    } catch let error {
      let command = "test" + (target.map { " --target \($0)" } ?? "")
      throw handleProcessRunnerError(error, command: command, timeout: actualTimeout)
    }
  }

  private func testArguments(for target: String?) -> [String] {
    var arguments = ["test"]

    // Add target if specified
    if let target = target {
      arguments.append("--target")
      arguments.append(target)
    }

    return arguments
  }
}
