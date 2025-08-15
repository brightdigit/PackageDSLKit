import Foundation

/// SPM command execution errors
public enum SPMExecutorError: Error, LocalizedError {
    case invalidPackagePath
    case swiftNotFound
    case packageNotFound
    case invalidJSON(String)
    case commandFailed(String, String) // command, error message
    
    public var errorDescription: String? {
        switch self {
        case .invalidPackagePath:
            return "Invalid package path provided"
        case .swiftNotFound:
            return "Swift executable not found in PATH"
        case .packageNotFound:
            return "Package.swift not found in the specified directory"
        case .invalidJSON(let error):
            return "Invalid JSON response from swift package dump-package: \(error)"
        case .commandFailed(let command, let error):
            return "Swift command '\(command)' failed: \(error)"
        }
    }
}

/// Executor for Swift Package Manager commands
public struct SPMExecutor {
    
    /// The package directory
    public let packageDirectory: URL
    
    /// Default timeout for SPM commands (in seconds)
    public let defaultTimeout: TimeInterval
    
    /// Initialize with a package directory
    /// - Parameters:
    ///   - packageDirectory: URL to the directory containing Package.swift
    ///   - defaultTimeout: Default timeout for commands (default: 60 seconds)
    public init(packageDirectory: URL, defaultTimeout: TimeInterval = 60) throws {
        // Verify the directory exists and contains a Package.swift
        let packageSwiftPath = packageDirectory.appendingPathComponent("Package.swift")
        guard FileManager.default.fileExists(atPath: packageSwiftPath.path) else {
            throw SPMExecutorError.packageNotFound
        }
        
        self.packageDirectory = packageDirectory
        self.defaultTimeout = defaultTimeout
    }
    
    /// Execute `swift package dump-package` and return parsed package info
    /// - Parameter timeout: Optional timeout override
    /// - Returns: Parsed SPMPackageInfo
    /// - Throws: SPMExecutorError on failure
    public func dumpPackage(timeout: TimeInterval? = nil) async throws -> SPMPackageInfo {
        let actualTimeout = timeout ?? defaultTimeout
        
        do {
            let result = try await ProcessRunner.swift(
                arguments: ["package", "dump-package"],
                workingDirectory: packageDirectory,
                timeout: actualTimeout
            )
            
            guard let jsonData = result.standardOutput.data(using: .utf8) else {
                throw SPMExecutorError.invalidJSON("Could not convert output to UTF-8 data")
            }
            
            let decoder = JSONDecoder()
            do {
                return try decoder.decode(SPMPackageInfo.self, from: jsonData)
            } catch {
                throw SPMExecutorError.invalidJSON(error.localizedDescription)
            }
            
        } catch let error as ProcessRunnerError {
            switch error {
            case .timeout:
                throw SPMExecutorError.commandFailed("package dump-package", "Command timed out after \(actualTimeout) seconds")
            case .nonZeroExit(let code, let stderr):
                throw SPMExecutorError.commandFailed("package dump-package", "Exit code \(code): \(stderr)")
            case .executionFailed(let message):
                throw SPMExecutorError.commandFailed("package dump-package", message)
            }
        }
    }
    
    /// Execute `swift package resolve` to resolve dependencies
    /// - Parameter timeout: Optional timeout override
    /// - Throws: SPMExecutorError on failure
    public func resolvePackage(timeout: TimeInterval? = nil) async throws {
        let actualTimeout = timeout ?? defaultTimeout
        
        do {
            _ = try await ProcessRunner.swift(
                arguments: ["package", "resolve"],
                workingDirectory: packageDirectory,
                timeout: actualTimeout
            )
        } catch let error as ProcessRunnerError {
            switch error {
            case .timeout:
                throw SPMExecutorError.commandFailed("package resolve", "Command timed out after \(actualTimeout) seconds")
            case .nonZeroExit(let code, let stderr):
                throw SPMExecutorError.commandFailed("package resolve", "Exit code \(code): \(stderr)")
            case .executionFailed(let message):
                throw SPMExecutorError.commandFailed("package resolve", message)
            }
        }
    }
    
    /// Execute `swift build` to build the package
    /// - Parameters:
    ///   - target: Optional specific target to build
    ///   - configuration: Build configuration (.debug or .release)
    ///   - timeout: Optional timeout override
    /// - Throws: SPMExecutorError on failure
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
            _ = try await ProcessRunner.swift(
                arguments: arguments,
                workingDirectory: packageDirectory,
                timeout: actualTimeout
            )
        } catch let error as ProcessRunnerError {
            let command = "build" + (target.map { " --target \($0)" } ?? "")
            switch error {
            case .timeout:
                throw SPMExecutorError.commandFailed(command, "Command timed out after \(actualTimeout) seconds")
            case .nonZeroExit(let code, let stderr):
                throw SPMExecutorError.commandFailed(command, "Exit code \(code): \(stderr)")
            case .executionFailed(let message):
                throw SPMExecutorError.commandFailed(command, message)
            }
        }
    }
    
    /// Execute `swift test` to run package tests
    /// - Parameters:
    ///   - target: Optional specific test target to run
    ///   - timeout: Optional timeout override
    /// - Throws: SPMExecutorError on failure
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
            _ = try await ProcessRunner.swift(
                arguments: arguments,
                workingDirectory: packageDirectory,
                timeout: actualTimeout
            )
        } catch let error as ProcessRunnerError {
            let command = "test" + (target.map { " --target \($0)" } ?? "")
            switch error {
            case .timeout:
                throw SPMExecutorError.commandFailed(command, "Command timed out after \(actualTimeout) seconds")
            case .nonZeroExit(let code, let stderr):
                throw SPMExecutorError.commandFailed(command, "Exit code \(code): \(stderr)")
            case .executionFailed(let message):
                throw SPMExecutorError.commandFailed(command, message)
            }
        }
    }
    
    /// Get basic package information (name, tools version) quickly
    /// - Parameter timeout: Optional timeout override  
    /// - Returns: Tuple of package name and tools version
    /// - Throws: SPMExecutorError on failure
    public func getPackageInfo(timeout: TimeInterval? = nil) async throws -> (name: String, toolsVersion: String) {
        let packageInfo = try await dumpPackage(timeout: timeout)
        return (name: packageInfo.name, toolsVersion: packageInfo.toolsVersion.version)
    }
}

/// Build configuration options
public enum BuildConfiguration {
    case debug
    case release
}

// MARK: - Convenience Extensions

extension SPMExecutor {
    
    /// Create SPMExecutor for the current working directory
    /// - Parameter defaultTimeout: Default timeout for commands
    /// - Returns: SPMExecutor instance
    /// - Throws: SPMExecutorError if no Package.swift found
    public static func current(defaultTimeout: TimeInterval = 60) throws -> SPMExecutor {
        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        return try SPMExecutor(packageDirectory: currentDirectory, defaultTimeout: defaultTimeout)
    }
    
    /// Create SPMExecutor for a specific path
    /// - Parameters:
    ///   - path: Path to package directory
    ///   - defaultTimeout: Default timeout for commands
    /// - Returns: SPMExecutor instance
    /// - Throws: SPMExecutorError if path invalid or no Package.swift found
    public static func at(path: String, defaultTimeout: TimeInterval = 60) throws -> SPMExecutor {
        let url = URL(fileURLWithPath: path)
        return try SPMExecutor(packageDirectory: url, defaultTimeout: defaultTimeout)
    }
}