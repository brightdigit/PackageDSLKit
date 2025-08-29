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
  /// Closure type for executing Swift commands
  public typealias SwiftCommandExecutor = @Sendable (
    _ arguments: [String],
    _ workingDirectory: URL?,
    _ timeout: TimeInterval
  ) async throws(ProcessRunnerError) -> ProcessResult

  /// The package directory
  public let packageDirectory: URL

  /// Default timeout for SPM commands (in seconds)
  public let defaultTimeout: TimeInterval

  /// The Swift command executor
  internal let swiftExecutor: SwiftCommandExecutor

  /// Initialize with a package directory and Swift command executor
  /// - Parameters:
  ///   - packageDirectory: URL to the directory containing Package.swift
  ///   - defaultTimeout: Default timeout for commands (default: 60 seconds)
  ///   - swiftExecutor: Closure to execute Swift commands (defaults to ProcessRunner.swift)
  public init(
    packageDirectory: URL,
    defaultTimeout: TimeInterval = 60,
    swiftExecutor: @escaping SwiftCommandExecutor
  ) throws(ExecutorError) {
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
}
