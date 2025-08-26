import Foundation

/// Represents a target dependency (can be by name or product)
public enum TargetDependency: Codable, Hashable {
    case byName(String, condition: TargetDependencyCondition?)
    case product(String, String, condition: TargetDependencyCondition?)
    
    private enum CodingKeys: String, CodingKey {
        case byName
        case product
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.byName) {
            var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .byName)
            let name = try unkeyedContainer.decode(String.self)
            let _ = try? unkeyedContainer.decode(String?.self) // Skip null value
            // TODO: Handle condition if needed
            let condition: TargetDependencyCondition? = nil 
            self = .byName(name, condition: condition)
        } else if container.contains(.product) {
            var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .product)
            let productName = try unkeyedContainer.decode(String.self)
            let packageName = try unkeyedContainer.decode(String.self)
            let _ = try? unkeyedContainer.decode(String?.self) // Skip null value
            
            // Try to decode condition if present
            let condition: TargetDependencyCondition?
            if !unkeyedContainer.isAtEnd {
                condition = try? unkeyedContainer.decode(TargetDependencyCondition.self)
            } else {
                condition = nil
            }
            
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
public struct TargetDependencyCondition: Codable, Hashable {
    public let platformNames: [String]?
    
    public init(platformNames: [String]? = nil) {
        self.platformNames = platformNames
    }
}

/// Represents resource rules for targets
public enum ResourceRule: Codable, Hashable {
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
public struct Resource: Codable, Hashable {
    public let path: String
    public let rule: ResourceRule
    
    public init(path: String, rule: ResourceRule) {
        self.path = path
        self.rule = rule
    }
}

/// Represents target types
public enum TargetType: String, Codable, Hashable {
    case regular
    case executable
    case test
    case plugin
    case macro
}

/// Represents a target in a Swift package
public struct Target: Codable, Hashable {
    public let name: String
    public let type: TargetType
    public let dependencies: [TargetDependency]
    public let exclude: [String]
    public let resources: [Resource]
    public let settings: [String] // Target-specific settings
    public let packageAccess: Bool
    
    public init(
        name: String,
        type: TargetType,
        dependencies: [TargetDependency] = [],
        exclude: [String] = [],
        resources: [Resource] = [],
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