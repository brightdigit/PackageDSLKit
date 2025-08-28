//
//  Executor.swift
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

/// Executor for Swift Package Manager commands
public struct Executor: Sendable {
  /// The package directory
  public let packageDirectory: URL

  /// Default timeout for SPM commands (in seconds)
  public let defaultTimeout: TimeInterval

  /// Closure type for executing Swift commands
  public typealias SwiftCommandExecutor = @Sendable (
    _ arguments: [String],
    _ workingDirectory: URL?,
    _ timeout: TimeInterval
  ) async throws -> ProcessResult

  /// The Swift command executor
  private let swiftExecutor: SwiftCommandExecutor

  /// Initialize with a package directory and Swift command executor
  /// - Parameters:
  ///   - packageDirectory: URL to the directory containing Package.swift
  ///   - defaultTimeout: Default timeout for commands (default: 60 seconds)
  ///   - swiftExecutor: Closure to execute Swift commands (defaults to ProcessRunner.swift)
  public init(
    packageDirectory: URL,
    defaultTimeout: TimeInterval = 60,
    swiftExecutor: @escaping SwiftCommandExecutor
  ) throws {
    // Verify the directory exists and contains a Package.swift
    let packageSwiftPath = packageDirectory.appendingPathComponent("Package.swift")
    print(packageSwiftPath)
    guard FileManager.default.fileExists(atPath: packageSwiftPath.path) else {
      throw ExecutorError.packageNotFound
    }

    self.packageDirectory = packageDirectory
    self.defaultTimeout = defaultTimeout
    self.swiftExecutor = swiftExecutor
  }

  #if canImport(Foundation) && (os(macOS) || os(Linux))
    public init(
      packageDirectory: URL,
      defaultTimeout: TimeInterval = 60
    ) throws {
      try self.init(
        packageDirectory: packageDirectory, defaultTimeout: defaultTimeout,
        swiftExecutor: ProcessRunner.swift)
    }
  #endif

  /// Execute `swift package dump-package` and return parsed package info
  /// - Parameter timeout: Optional timeout override
  /// - Returns: Parsed PackageInfo
  /// - Throws: ExecutorError on failure
  public func dumpPackage(timeout: TimeInterval? = nil) async throws -> PackageInfo {
    let actualTimeout = timeout ?? defaultTimeout

    do {
      let result = try await swiftExecutor(
        ["package", "dump-package"],
        packageDirectory,
        actualTimeout
      )

      print(result.standardOutput)
      guard let jsonData = result.standardOutput.data(using: .utf8) else {
        throw ExecutorError.invalidJSON("Could not convert output to UTF-8 data")
      }

      let decoder = JSONDecoder()
      do {
        return try decoder.decode(PackageInfo.self, from: jsonData)
      } catch {
        dump(error)
        throw ExecutorError.invalidJSON(error.localizedDescription)
      }
    } catch let error as ProcessRunnerError {
      switch error {
      case .timeout:
        throw ExecutorError.commandFailed(
          "package dump-package", "Command timed out after \(actualTimeout) seconds")
      case .nonZeroExit(let code, let stderr):
        throw ExecutorError.commandFailed("package dump-package", "Exit code \(code): \(stderr)")
      case .executionFailed(let message):
        throw ExecutorError.commandFailed("package dump-package", message)
      }
    }
  }

  /// Execute `swift package resolve` to resolve dependencies
  /// - Parameter timeout: Optional timeout override
  /// - Throws: ExecutorError on failure
  public func resolvePackage(timeout: TimeInterval? = nil) async throws {
    let actualTimeout = timeout ?? defaultTimeout

    do {
      _ = try await swiftExecutor(
        ["package", "resolve"],
        packageDirectory,
        actualTimeout
      )
    } catch let error as ProcessRunnerError {
      switch error {
      case .timeout:
        throw ExecutorError.commandFailed(
          "package resolve", "Command timed out after \(actualTimeout) seconds")
      case .nonZeroExit(let code, let stderr):
        throw ExecutorError.commandFailed("package resolve", "Exit code \(code): \(stderr)")
      case .executionFailed(let message):
        throw ExecutorError.commandFailed("package resolve", message)
      }
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
  ) async throws {
    let actualTimeout = timeout ?? defaultTimeout

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

    do {
      _ = try await swiftExecutor(
        arguments,
        packageDirectory,
        actualTimeout
      )
    } catch let error as ProcessRunnerError {
      let command = "build" + (target.map { " --target \($0)" } ?? "")
      switch error {
      case .timeout:
        throw ExecutorError.commandFailed(
          command, "Command timed out after \(actualTimeout) seconds")
      case .nonZeroExit(let code, let stderr):
        throw ExecutorError.commandFailed(command, "Exit code \(code): \(stderr)")
      case .executionFailed(let message):
        throw ExecutorError.commandFailed(command, message)
      }
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
  ) async throws {
    let actualTimeout = timeout ?? defaultTimeout

    var arguments = ["test"]

    // Add target if specified
    if let target = target {
      arguments.append("--target")
      arguments.append(target)
    }

    do {
      _ = try await swiftExecutor(
        arguments,
        packageDirectory,
        actualTimeout
      )
    } catch let error as ProcessRunnerError {
      let command = "test" + (target.map { " --target \($0)" } ?? "")
      switch error {
      case .timeout:
        throw ExecutorError.commandFailed(
          command, "Command timed out after \(actualTimeout) seconds")
      case .nonZeroExit(let code, let stderr):
        throw ExecutorError.commandFailed(command, "Exit code \(code): \(stderr)")
      case .executionFailed(let message):
        throw ExecutorError.commandFailed(command, message)
      }
    }
  }

  /// Get basic package information (name, tools version) quickly
  /// - Parameter timeout: Optional timeout override
  /// - Returns: Tuple of package name and tools version
  /// - Throws: ExecutorError on failure
  public func getPackageInfo(timeout: TimeInterval? = nil) async throws -> (
    name: String, toolsVersion: String
  ) {
    let packageInfo = try await dumpPackage(timeout: timeout)
    return (name: packageInfo.name, toolsVersion: packageInfo.toolsVersion.version)
  }
}

// MARK: - Convenience Extensions
#if canImport(Foundation) && (os(macOS) || os(Linux))
  extension Executor {
    /// Create Executor for the current working directory
    /// - Parameter defaultTimeout: Default timeout for commands
    /// - Returns: Executor instance
    /// - Throws: ExecutorError if no Package.swift found
    public static func current(defaultTimeout: TimeInterval = 60) throws -> Executor {
      let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      return try Executor(packageDirectory: currentDirectory, defaultTimeout: defaultTimeout)
    }

    /// Create Executor for a specific path
    /// - Parameters:
    ///   - path: Path to package directory
    ///   - defaultTimeout: Default timeout for commands
    /// - Returns: Executor instance
    /// - Throws: ExecutorError if path invalid or no Package.swift found
    public static func at(path: String, defaultTimeout: TimeInterval = 60) throws -> Executor {
      let url = URL(fileURLWithPath: path)
      return try Executor(packageDirectory: url, defaultTimeout: defaultTimeout)
    }
  }
#endif
