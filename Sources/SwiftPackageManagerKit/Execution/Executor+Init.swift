//
//  Executor+Init.swift
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
