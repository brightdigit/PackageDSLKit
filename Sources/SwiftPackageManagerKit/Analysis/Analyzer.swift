import Foundation

/// Errors that can occur during SPM analysis
public enum AnalysisError: Error, LocalizedError, Sendable {
  case invalidJSON(String)
  case malformedPackageStructure(String)
  case unsupportedFormat(String)

  public var errorDescription: String? {
    switch self {
    case .invalidJSON(let details):
      return "Invalid JSON format: \(details)"
    case .malformedPackageStructure(let details):
      return "Malformed package structure: \(details)"
    case .unsupportedFormat(let details):
      return "Unsupported format: \(details)"
    }
  }
}

/// Analyzer for parsing Swift Package Manager JSON output
public struct Analyzer: Sendable {
  /// JSON decoder with custom configuration for SPM data
  private let decoder: JSONDecoder

  /// Initialize with custom JSON decoder configuration
  /// - Parameter decoder: Custom JSONDecoder (uses default if nil)
  public init(decoder: JSONDecoder? = nil) {
    self.decoder =
      decoder
      ?? {
        let decoder = JSONDecoder()
        // Configure decoder for SPM JSON format
        decoder.dateDecodingStrategy = .iso8601
        return decoder
      }()
  }

  /// Analyze package JSON data and return parsed package information
  /// - Parameter data: Raw JSON data from swift package dump-package
  /// - Returns: Parsed PackageInfo
  /// - Throws: AnalysisError for parsing failures
  public func analyzePackage(data: Data) throws -> PackageInfo {
    guard !data.isEmpty else {
      throw AnalysisError.invalidJSON("Empty data provided")
    }

    do {
      let packageInfo = try decoder.decode(PackageInfo.self, from: data)

      // Basic validation to ensure we have essential fields
      try validateBasicStructure(packageInfo)

      return packageInfo
    } catch let decodingError as DecodingError {
      throw AnalysisError.invalidJSON(decodingError.localizedDescription)
    } catch let error as AnalysisError {
      throw error
    } catch {
      throw AnalysisError.malformedPackageStructure(error.localizedDescription)
    }
  }

  /// Analyze package from JSON string
  /// - Parameter jsonString: JSON string from swift package dump-package
  /// - Returns: Parsed PackageInfo
  /// - Throws: AnalysisError for parsing failures
  public func analyzePackage(jsonString: String) throws -> PackageInfo {
    guard let data = jsonString.data(using: .utf8) else {
      throw AnalysisError.invalidJSON("Could not convert string to UTF-8 data")
    }
    return try analyzePackage(data: data)
  }

  /// Analyze package directly from file path
  /// - Parameter filePath: Path to JSON file containing dump-package output
  /// - Returns: Parsed PackageInfo
  /// - Throws: AnalysisError for parsing failures
  public func analyzePackage(filePath: String) throws -> PackageInfo {
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
      return try analyzePackage(data: data)
    } catch {
      throw AnalysisError.invalidJSON(
        "Could not read file at \(filePath): \(error.localizedDescription)")
    }
  }

  /// Extract basic package summary from analyzed data
  /// - Parameter packageInfo: Parsed package information
  /// - Returns: Dictionary with key package metrics
  public func extractSummary(from packageInfo: PackageInfo) -> [String: Any] {
    [
      "name": packageInfo.name,
      "toolsVersion": packageInfo.toolsVersion.version,
      "platformCount": packageInfo.platforms.count,
      "productCount": packageInfo.products.count,
      "targetCount": packageInfo.targets.count,
      "dependencyCount": packageInfo.dependencies.count,
      "libraryProducts": packageInfo.libraryProducts.count,
      "executableProducts": packageInfo.executableProducts.count,
      "regularTargets": packageInfo.targets.filter { $0.type == .regular }.count,
      "testTargets": packageInfo.targets.filter { $0.type == .test }.count,
      "executableTargets": packageInfo.targets.filter { $0.type == .executable }.count,
    ]
  }

  /// Perform basic validation on parsed package structure
  /// - Parameter packageInfo: Parsed package information to validate
  /// - Throws: AnalysisError if basic structure is invalid
  private func validateBasicStructure(_ packageInfo: PackageInfo) throws {
    // Validate package name is not empty
    guard !packageInfo.name.isEmpty else {
      throw AnalysisError.malformedPackageStructure("Package name cannot be empty")
    }

    // Validate tools version is present
    guard !packageInfo.toolsVersion.version.isEmpty else {
      throw AnalysisError.malformedPackageStructure("Tools version cannot be empty")
    }

    // Validate that products reference existing targets
    let targetNames = Set(packageInfo.targets.map { $0.name })
    for product in packageInfo.products {
      for targetName in product.targets {
        guard targetNames.contains(targetName) else {
          throw AnalysisError.malformedPackageStructure(
            "Product '\(product.name)' references non-existent target '\(targetName)'"
          )
        }
      }
    }
  }
}

// MARK: - Convenience Extensions

extension Analyzer {
  /// Default shared analyzer instance
  public static let shared = Analyzer()

  /// Quick analysis of package data with error handling
  /// - Parameter data: JSON data from swift package dump-package
  /// - Returns: Result containing either PackageInfo or AnalysisError
  public static func analyze(_ data: Data) -> Result<PackageInfo, AnalysisError> {
    do {
      let packageInfo = try shared.analyzePackage(data: data)
      return .success(packageInfo)
    } catch let error as AnalysisError {
      return .failure(error)
    } catch {
      return .failure(.malformedPackageStructure(error.localizedDescription))
    }
  }

  /// Quick analysis of package JSON string with error handling
  /// - Parameter jsonString: JSON string from swift package dump-package
  /// - Returns: Result containing either PackageInfo or AnalysisError
  public static func analyze(_ jsonString: String) -> Result<PackageInfo, AnalysisError> {
    do {
      let packageInfo = try shared.analyzePackage(jsonString: jsonString)
      return .success(packageInfo)
    } catch let error as AnalysisError {
      return .failure(error)
    } catch {
      return .failure(.malformedPackageStructure(error.localizedDescription))
    }
  }
}
