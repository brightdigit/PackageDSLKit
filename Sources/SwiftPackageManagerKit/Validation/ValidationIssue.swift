import Foundation

/// Severity levels for validation issues
public enum ValidationSeverity: String, CaseIterable, Comparable, Codable, Sendable {
    case error = "error"
    case warning = "warning"
    case info = "info"
    
    public static func < (lhs: ValidationSeverity, rhs: ValidationSeverity) -> Bool {
        let order: [ValidationSeverity] = [.info, .warning, .error]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

/// Categories of validation issues
public enum ValidationCategory: String, CaseIterable, Codable, Sendable {
    case structure = "structure"
    case dependencies = "dependencies"
    case versions = "versions"
    case platforms = "platforms"
    case targets = "targets"
    case products = "products"
    case configuration = "configuration"
}

/// Represents a validation issue found in a Swift package
public struct ValidationIssue: Codable, Hashable, Sendable {
    /// Unique identifier for this issue type
    public let id: String
    
    /// Human-readable description of the issue
    public let message: String
    
    /// Severity level of the issue
    public let severity: ValidationSeverity
    
    /// Category of the validation issue
    public let category: ValidationCategory
    
    /// Location or context where the issue was found
    public let location: String?
    
    /// Suggested fix or recommendation
    public let recommendation: String?
    
    /// Additional context or details
    public let context: [String: String]
    
    public init(
        id: String,
        message: String,
        severity: ValidationSeverity,
        category: ValidationCategory,
        location: String? = nil,
        recommendation: String? = nil,
        context: [String: String] = [:]
    ) {
        self.id = id
        self.message = message
        self.severity = severity
        self.category = category
        self.location = location
        self.recommendation = recommendation
        self.context = context
    }
}

// MARK: - Predefined Issue Types

extension ValidationIssue {
    
    /// Missing product issue
    public static func missingProduct(name: String) -> ValidationIssue {
        return ValidationIssue(
            id: "missing-product",
            message: "Product '\(name)' is referenced but not defined",
            severity: .error,
            category: .products,
            location: "products",
            recommendation: "Add a product definition for '\(name)' or remove references to it"
        )
    }
    
    /// Orphaned target issue
    public static func orphanedTarget(name: String) -> ValidationIssue {
        return ValidationIssue(
            id: "orphaned-target",
            message: "Target '\(name)' is not used by any product",
            severity: .warning,
            category: .targets,
            location: "targets.\(name)",
            recommendation: "Add '\(name)' to a product or remove it if unused"
        )
    }
    
    /// Circular dependency issue
    public static func circularDependency(targets: [String]) -> ValidationIssue {
        let targetList = targets.joined(separator: " -> ")
        return ValidationIssue(
            id: "circular-dependency",
            message: "Circular dependency detected: \(targetList)",
            severity: .error,
            category: .dependencies,
            location: "targets",
            recommendation: "Remove or restructure dependencies to eliminate the cycle",
            context: ["targets": targets.joined(separator: ",")]
        )
    }
    
    /// Invalid version requirement issue
    public static func invalidVersionRequirement(dependency: String, requirement: String) -> ValidationIssue {
        return ValidationIssue(
            id: "invalid-version-requirement",
            message: "Invalid version requirement '\(requirement)' for dependency '\(dependency)'",
            severity: .error,
            category: .versions,
            location: "dependencies.\(dependency)",
            recommendation: "Use a valid semantic version range (e.g., \"1.0.0\"..<\"2.0.0\")"
        )
    }
    
    /// Unsupported platform version issue
    public static func unsupportedPlatformVersion(platform: String, version: String) -> ValidationIssue {
        return ValidationIssue(
            id: "unsupported-platform-version",
            message: "Unsupported version '\(version)' for platform '\(platform)'",
            severity: .warning,
            category: .platforms,
            location: "platforms.\(platform)",
            recommendation: "Use a supported version for \(platform)"
        )
    }
    
    /// Missing dependency issue
    public static func missingDependency(target: String, dependency: String) -> ValidationIssue {
        return ValidationIssue(
            id: "missing-dependency",
            message: "Target '\(target)' references undefined dependency '\(dependency)'",
            severity: .error,
            category: .dependencies,
            location: "targets.\(target).dependencies",
            recommendation: "Add '\(dependency)' to package dependencies or remove the reference"
        )
    }
    
    /// Empty target issue
    public static func emptyTarget(name: String) -> ValidationIssue {
        return ValidationIssue(
            id: "empty-target",
            message: "Target '\(name)' has no source files",
            severity: .warning,
            category: .targets,
            location: "targets.\(name)",
            recommendation: "Add source files to the target or remove it if unused"
        )
    }
    
    /// Conflicting target names issue
    public static func conflictingTargetNames(names: [String]) -> ValidationIssue {
        return ValidationIssue(
            id: "conflicting-target-names",
            message: "Multiple targets with similar names detected: \(names.joined(separator: ", "))",
            severity: .warning,
            category: .structure,
            location: "targets",
            recommendation: "Consider using more distinct target names to avoid confusion"
        )
    }
    
    /// Missing test target issue
    public static func missingTestTarget(for target: String) -> ValidationIssue {
        return ValidationIssue(
            id: "missing-test-target",
            message: "No test target found for '\(target)'",
            severity: .info,
            category: .targets,
            location: "targets",
            recommendation: "Consider adding a test target for '\(target)' to improve code quality"
        )
    }
}

// MARK: - Validation Result

/// Result of a validation operation
public struct ValidationResult: Codable {
    /// All validation issues found
    public let issues: [ValidationIssue]
    
    /// Timestamp when validation was performed
    public let timestamp: Date
    
    /// Package name that was validated
    public let packageName: String
    
    /// Summary of issues by severity
    public var summary: [ValidationSeverity: Int] {
        Dictionary(grouping: issues, by: { $0.severity })
            .mapValues { $0.count }
    }
    
    /// Whether validation passed (no errors)
    public var isValid: Bool {
        return !issues.contains { $0.severity == .error }
    }
    
    /// Total number of issues
    public var totalIssues: Int {
        return issues.count
    }
    
    public init(issues: [ValidationIssue], packageName: String, timestamp: Date = Date()) {
        self.issues = issues
        self.packageName = packageName
        self.timestamp = timestamp
    }
}

// MARK: - Extensions

extension ValidationResult {
    
    /// Get issues by severity level
    /// - Parameter severity: The severity level to filter by
    /// - Returns: Array of issues with the specified severity
    public func issues(withSeverity severity: ValidationSeverity) -> [ValidationIssue] {
        return issues.filter { $0.severity == severity }
    }
    
    /// Get issues by category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of issues in the specified category
    public func issues(inCategory category: ValidationCategory) -> [ValidationIssue] {
        return issues.filter { $0.category == category }
    }
    
    /// Generate a formatted summary string
    /// - Returns: Human-readable summary of validation results
    public func formattedSummary() -> String {
        if isValid {
            return "✅ Package '\(packageName)' validation passed with \(totalIssues) issues (no errors)"
        } else {
            let errorCount = summary[.error] ?? 0
            let warningCount = summary[.warning] ?? 0
            let infoCount = summary[.info] ?? 0
            
            var parts: [String] = []
            if errorCount > 0 { parts.append("\(errorCount) error\(errorCount == 1 ? "" : "s")") }
            if warningCount > 0 { parts.append("\(warningCount) warning\(warningCount == 1 ? "" : "s")") }
            if infoCount > 0 { parts.append("\(infoCount) info") }
            
            return "❌ Package '\(packageName)' validation failed: \(parts.joined(separator: ", "))"
        }
    }
}
