import Foundation

/// Validator for Swift Package Manager package configurations
public struct Validator: Sendable {
    
    /// Configuration options for validation
    public struct Configuration: Sendable {
        /// Whether to check for missing test targets
        public let checkTestTargets: Bool
        
        /// Whether to validate platform versions
        public let validatePlatforms: Bool
        
        /// Whether to detect circular dependencies
        public let detectCircularDependencies: Bool
        
        /// Whether to check for orphaned targets
        public let checkOrphanedTargets: Bool
        
        /// Maximum allowed dependency depth for circular detection
        public let maxDependencyDepth: Int
        
        public init(
            checkTestTargets: Bool = true,
            validatePlatforms: Bool = true,
            detectCircularDependencies: Bool = true,
            checkOrphanedTargets: Bool = true,
            maxDependencyDepth: Int = 50
        ) {
            self.checkTestTargets = checkTestTargets
            self.validatePlatforms = validatePlatforms
            self.detectCircularDependencies = detectCircularDependencies
            self.checkOrphanedTargets = checkOrphanedTargets
            self.maxDependencyDepth = maxDependencyDepth
        }
        
        /// Default configuration with all checks enabled
        public static let `default` = Configuration()
        
        /// Strict configuration with all validations enabled
        public static let strict = Configuration(
            checkTestTargets: true,
            validatePlatforms: true,
            detectCircularDependencies: true,
            checkOrphanedTargets: true
        )
        
        /// Lenient configuration with only error-level checks
        public static let lenient = Configuration(
            checkTestTargets: false,
            validatePlatforms: false,
            detectCircularDependencies: true,
            checkOrphanedTargets: false
        )
    }
    
    /// Validation configuration
    public let configuration: Configuration
    
    /// Initialize validator with configuration
    /// - Parameter configuration: Validation configuration to use
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
    }
    
    /// Validate complete package structure and return all issues
    /// - Parameter package: The package information to validate
    /// - Returns: ValidationResult containing all found issues
    public func validate(_ package: PackageInfo) -> ValidationResult {
        var issues: [ValidationIssue] = []
        
        // Basic structure validation
        issues.append(contentsOf: validatePackageStructure(package))
        
        // Dependency validation
        issues.append(contentsOf: validateDependencies(package))
        
        // Version requirements validation
        issues.append(contentsOf: validateVersionRequirements(package.dependencies))
        
        // Platform validation
        if configuration.validatePlatforms {
            issues.append(contentsOf: validatePlatforms(package.platforms))
        }
        
        // Circular dependency detection
        if configuration.detectCircularDependencies {
            issues.append(contentsOf: detectCircularDependencies(in: package))
        }
        
        // Orphaned targets check
        if configuration.checkOrphanedTargets {
            issues.append(contentsOf: findOrphanedTargets(in: package))
        }
        
        // Test targets check
        if configuration.checkTestTargets {
            issues.append(contentsOf: checkTestTargets(in: package))
        }
        
        return ValidationResult(issues: issues, packageName: package.name)
    }
    
    /// Validate basic package structure
    /// - Parameter package: Package to validate
    /// - Returns: Array of validation issues
    public func validatePackageStructure(_ package: PackageInfo) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        // Check that all product targets exist
        let targetNames = Set(package.targets.map { $0.name })
        for product in package.products {
            for targetName in product.targets {
                if !targetNames.contains(targetName) {
                    issues.append(.missingProduct(name: targetName))
                }
            }
        }
        
        // Check for conflicting target names (case-insensitive)
        let lowercaseNames = package.targets.map { $0.name.lowercased() }
        let duplicates = Dictionary(grouping: lowercaseNames, by: { $0 })
            .filter { $1.count > 1 }
            .keys
        
        if !duplicates.isEmpty {
            let conflictingNames = package.targets
                .map { $0.name }
                .filter { duplicates.contains($0.lowercased()) }
            issues.append(.conflictingTargetNames(names: Array(Set(conflictingNames))))
        }
        
        // Check for empty targets (targets with no dependencies and no clear purpose)
        for target in package.targets {
            if target.dependencies.isEmpty && target.type == .regular {
                // This could be a leaf target, which might be fine, so make it a warning
                if !package.products.contains(where: { $0.targets.contains(target.name) }) {
                    issues.append(.emptyTarget(name: target.name))
                }
            }
        }
        
        return issues
    }
    
    /// Validate package dependencies
    /// - Parameter package: Package to validate
    /// - Returns: Array of validation issues
    public func validateDependencies(_ package: PackageInfo) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        // Get all available product names from dependencies
        let dependencyNames = Set(package.dependencies.map { $0.identity })
        
        // Check target dependencies
        for target in package.targets {
            for dependency in target.dependencies {
                switch dependency {
                case .byName(let name, _):
                    // Check if it's a target in this package
                    if !package.targets.contains(where: { $0.name == name }) {
                        issues.append(.missingDependency(target: target.name, dependency: name))
                    }
                case .product(let productName, let packageName, _):
                    // Check if the package dependency exists
                    if !dependencyNames.contains(packageName) {
                        issues.append(.missingDependency(target: target.name, dependency: "\(productName) from \(packageName)"))
                    }
                }
            }
        }
        
        return issues
    }
    
    /// Validate version requirements for dependencies
    /// - Parameter dependencies: Array of package dependencies to validate
    /// - Returns: Array of validation issues
    public func validateVersionRequirements(_ dependencies: [Dependency]) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        for dependency in dependencies {
            switch dependency {
            case .sourceControl(let sourceControl):
                let requirement = sourceControl.requirement
                let identity = sourceControl.identity
                
                switch requirement {
                case .range(let lowerBound, let upperBound):
                    // Validate semantic version format
                    if !isValidSemanticVersion(lowerBound) {
                        issues.append(.invalidVersionRequirement(
                            dependency: identity,
                            requirement: "Invalid lower bound: \(lowerBound)"
                        ))
                    }
                    if !isValidSemanticVersion(upperBound) {
                        issues.append(.invalidVersionRequirement(
                            dependency: identity,
                            requirement: "Invalid upper bound: \(upperBound)"
                        ))
                    }
                    
                    // Check that lower bound is less than upper bound
                    if isValidSemanticVersion(lowerBound) && isValidSemanticVersion(upperBound) {
                        if compareSemanticVersions(lowerBound, upperBound) >= 0 {
                            issues.append(.invalidVersionRequirement(
                                dependency: identity,
                                requirement: "Lower bound \(lowerBound) is not less than upper bound \(upperBound)"
                            ))
                        }
                    }
                    
                case .exact(let version):
                    if !isValidSemanticVersion(version) {
                        issues.append(.invalidVersionRequirement(
                            dependency: identity,
                            requirement: "Invalid exact version: \(version)"
                        ))
                    }
                    
                case .revision(let revision):
                    // Basic validation for revision (should be a commit hash)
                    if revision.isEmpty || revision.count < 7 {
                        issues.append(.invalidVersionRequirement(
                            dependency: identity,
                            requirement: "Invalid revision: \(revision)"
                        ))
                    }
                    
                case .branch(let branch):
                    // Basic validation for branch name
                    if branch.isEmpty {
                        issues.append(.invalidVersionRequirement(
                            dependency: identity,
                            requirement: "Empty branch name"
                        ))
                    }
                }
                
            case .fileSystem:
                // File system dependencies don't have version requirements to validate
                break
            }
        }
        
        return issues
    }
    
    /// Validate platform specifications
    /// - Parameter platforms: Array of platforms to validate
    /// - Returns: Array of validation issues
    public func validatePlatforms(_ platforms: [Platform]) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        let supportedPlatforms = ["macos", "ios", "watchos", "tvos", "linux", "windows"]
        let minimumVersions: [String: String] = [
            "macos": "10.15",
            "ios": "13.0",
            "watchos": "6.0",
            "tvos": "13.0"
        ]
        
        for platform in platforms {
            // Check if platform is supported
            if !supportedPlatforms.contains(platform.platformName.lowercased()) {
                issues.append(.unsupportedPlatformVersion(
                    platform: platform.platformName,
                    version: "Unsupported platform"
                ))
                continue
            }
            
            // Check minimum version requirements
            if let minimumVersion = minimumVersions[platform.platformName.lowercased()] {
                if compareSemanticVersions(platform.version, minimumVersion) < 0 {
                    issues.append(.unsupportedPlatformVersion(
                        platform: platform.platformName,
                        version: "Version \(platform.version) is below minimum \(minimumVersion)"
                    ))
                }
            }
            
            // Validate version format
            if !isValidSemanticVersion(platform.version) {
                issues.append(.unsupportedPlatformVersion(
                    platform: platform.platformName,
                    version: "Invalid version format: \(platform.version)"
                ))
            }
        }
        
        return issues
    }
    
    /// Detect circular dependencies in target dependency graph
    /// - Parameter package: Package to analyze
    /// - Returns: Array of validation issues for circular dependencies
    public func detectCircularDependencies(in package: PackageInfo) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        let targetMap = Dictionary(uniqueKeysWithValues: package.targets.map { ($0.name, $0) })
        
        // Use DFS to detect cycles
        for target in package.targets {
            var visited: Set<String> = []
            var recursionStack: Set<String> = []
            var path: [String] = []
            
            if hasCycle(target: target.name, targetMap: targetMap, visited: &visited, recursionStack: &recursionStack, path: &path) {
                // Find the cycle in the path
                if let cycleStart = path.firstIndex(of: target.name) {
                    let cycle = Array(path[cycleStart...]) + [target.name]
                    issues.append(.circularDependency(targets: cycle))
                }
            }
        }
        
        return issues
    }
    
    /// Find orphaned targets (targets not used by any product)
    /// - Parameter package: Package to analyze
    /// - Returns: Array of validation issues for orphaned targets
    public func findOrphanedTargets(in package: PackageInfo) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        // Get all targets used by products
        let usedTargets = Set(package.products.flatMap { $0.targets })
        
        // Find targets not used by any product
        for target in package.targets {
            if !usedTargets.contains(target.name) && target.type != .test {
                issues.append(.orphanedTarget(name: target.name))
            }
        }
        
        return issues
    }
    
    /// Check for missing test targets
    /// - Parameter package: Package to analyze
    /// - Returns: Array of validation issues for missing test targets
    public func checkTestTargets(in package: PackageInfo) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        let testTargets = Set(package.targets.filter { $0.type == .test }.map { $0.name })
        let regularTargets = package.targets.filter { $0.type == .regular }
        
        for target in regularTargets {
            // Look for corresponding test target
            let expectedTestNames = [
                "\(target.name)Tests",
                "\(target.name)Test",
                "Test\(target.name)"
            ]
            
            let hasTestTarget = expectedTestNames.contains { testTargets.contains($0) }
            if !hasTestTarget {
                issues.append(.missingTestTarget(for: target.name))
            }
        }
        
        return issues
    }
    
    // MARK: - Private Helper Methods
    
    /// Check if a string is a valid semantic version
    private func isValidSemanticVersion(_ version: String) -> Bool {
        let pattern = #"^\d+\.\d+\.\d+(-[a-zA-Z0-9\-\.]*)?(\+[a-zA-Z0-9\-\.]*)?$"#
        return version.range(of: pattern, options: .regularExpression) != nil
    }
    
    /// Compare two semantic versions (-1: first < second, 0: equal, 1: first > second)
    private func compareSemanticVersions(_ version1: String, _ version2: String) -> Int {
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxCount = max(v1Components.count, v2Components.count)
        
        for i in 0..<maxCount {
            let v1Value = i < v1Components.count ? v1Components[i] : 0
            let v2Value = i < v2Components.count ? v2Components[i] : 0
            
            if v1Value < v2Value { return -1 }
            if v1Value > v2Value { return 1 }
        }
        
        return 0
    }
    
    /// Recursive function to detect cycles in dependency graph
    private func hasCycle(
        target: String,
        targetMap: [String: Target],
        visited: inout Set<String>,
        recursionStack: inout Set<String>,
        path: inout [String]
    ) -> Bool {
        if recursionStack.contains(target) {
            return true
        }
        
        if visited.contains(target) {
            return false
        }
        
        visited.insert(target)
        recursionStack.insert(target)
        path.append(target)
        
        if let targetInfo = targetMap[target] {
            for dependency in targetInfo.dependencies {
                switch dependency {
                case .byName(let depName, _):
                    if hasCycle(target: depName, targetMap: targetMap, visited: &visited, recursionStack: &recursionStack, path: &path) {
                        return true
                    }
                case .product:
                    // Product dependencies are external, don't cause internal cycles
                    break
                }
            }
        }
        
        recursionStack.remove(target)
        path.removeLast()
        return false
    }
}

// MARK: - Convenience Extensions

extension Validator {
    
    /// Shared validator instance with default configuration
    public static let shared = Validator()
    
    /// Quick validation with default configuration
    /// - Parameter package: Package to validate
    /// - Returns: ValidationResult
    public static func validate(_ package: PackageInfo) -> ValidationResult {
        return shared.validate(package)
    }
}