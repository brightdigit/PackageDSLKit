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