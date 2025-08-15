import Foundation

/// Represents a target dependency (can be by name or product)
public enum SPMTargetDependency: Codable, Hashable {
    case byName(String, condition: SPMTargetDependencyCondition?)
    case product(String, String, condition: SPMTargetDependencyCondition?)
    
    private enum CodingKeys: String, CodingKey {
        case byName
        case product
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let byNameArray = try? container.decode([String?].self, forKey: .byName) {
            let name = byNameArray[0] ?? ""
            let condition: SPMTargetDependencyCondition? = nil // Simplified for now
            self = .byName(name, condition: condition)
        } else if let productArray = try? container.decode([String?].self, forKey: .product) {
            let productName = productArray[0] ?? ""
            let packageName = productArray[1] ?? ""
            let condition: SPMTargetDependencyCondition? = nil // Simplified for now
            self = .product(productName, packageName, condition: condition)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown target dependency type")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .byName(let name, _):
            try container.encode([name, nil], forKey: .byName)
        case .product(let productName, let packageName, _):
            try container.encode([productName, packageName, nil, nil], forKey: .product)
        }
    }
}

/// Represents platform-specific conditions for dependencies
public struct SPMTargetDependencyCondition: Codable, Hashable {
    public let platformNames: [String]?
    
    public init(platformNames: [String]? = nil) {
        self.platformNames = platformNames
    }
}

/// Represents resource rules for targets
public enum SPMResourceRule: Codable, Hashable {
    case copy
    case process
    
    private enum CodingKeys: String, CodingKey {
        case copy
        case process
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.copy) {
            self = .copy
        } else if container.contains(.process) {
            self = .process
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown resource rule type")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .copy:
            try container.encode([String: String](), forKey: .copy)
        case .process:
            try container.encode([String: String](), forKey: .process)
        }
    }
}

/// Represents a resource in a target
public struct SPMResource: Codable, Hashable {
    public let path: String
    public let rule: SPMResourceRule
    
    public init(path: String, rule: SPMResourceRule) {
        self.path = path
        self.rule = rule
    }
}

/// Represents target types
public enum SPMTargetType: String, Codable, Hashable {
    case regular
    case executable
    case test
    case plugin
    case macro
}

/// Represents a target in a Swift package
public struct SPMTarget: Codable, Hashable {
    public let name: String
    public let type: SPMTargetType
    public let dependencies: [SPMTargetDependency]
    public let exclude: [String]
    public let resources: [SPMResource]
    public let settings: [String] // Target-specific settings
    public let packageAccess: Bool
    
    public init(
        name: String,
        type: SPMTargetType,
        dependencies: [SPMTargetDependency] = [],
        exclude: [String] = [],
        resources: [SPMResource] = [],
        settings: [String] = [],
        packageAccess: Bool = true
    ) {
        self.name = name
        self.type = type
        self.dependencies = dependencies
        self.exclude = exclude
        self.resources = resources
        self.settings = settings
        self.packageAccess = packageAccess
    }
}