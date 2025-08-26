import Foundation

/// Represents a dependency location (remote or file system)
public enum DependencyLocation: Codable, Hashable {
    case remote(urlString: String)
    case fileSystem(path: String)
    
    private enum CodingKeys: String, CodingKey {
        case remote
        case fileSystem
    }
    
    private enum RemoteKeys: String, CodingKey {
        case urlString
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let remoteContainer = try? container.nestedContainer(keyedBy: RemoteKeys.self, forKey: .remote) {
            let urlString = try remoteContainer.decode(String.self, forKey: .urlString)
            self = .remote(urlString: urlString)
        } else if let path = try? container.decode(String.self, forKey: .fileSystem) {
            self = .fileSystem(path: path)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown dependency location type")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .remote(let urlString):
            var remoteContainer = container.nestedContainer(keyedBy: RemoteKeys.self, forKey: .remote)
            try remoteContainer.encode(urlString, forKey: .urlString)
        case .fileSystem(let path):
            try container.encode(path, forKey: .fileSystem)
        }
    }
}

/// Represents a trait for a dependency
public struct DependencyTrait: Codable, Hashable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

/// Represents a source control dependency
public struct SourceControlDependency: Codable, Hashable {
    public let identity: String
    public let location: DependencyLocation
    public let productFilter: String?
    public let requirement: VersionRequirement
    public let traits: [DependencyTrait]
    
    public init(
        identity: String,
        location: DependencyLocation,
        productFilter: String? = nil,
        requirement: VersionRequirement,
        traits: [DependencyTrait] = []
    ) {
        self.identity = identity
        self.location = location
        self.productFilter = productFilter
        self.requirement = requirement
        self.traits = traits
    }
}

/// Represents a file system dependency
public struct FileSystemDependency: Codable, Hashable {
    public let identity: String
    public let path: String
    public let productFilter: String?
    public let traits: [DependencyTrait]
    
    public init(
        identity: String,
        path: String,
        productFilter: String? = nil,
        traits: [DependencyTrait] = []
    ) {
        self.identity = identity
        self.path = path
        self.productFilter = productFilter
        self.traits = traits
    }
}

/// Represents a package dependency (can be source control or file system)
public enum Dependency: Codable, Hashable {
    case sourceControl(SourceControlDependency)
    case fileSystem(FileSystemDependency)
    
    private enum CodingKeys: String, CodingKey {
        case sourceControl
        case fileSystem
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let sourceControl = try? container.decode([SourceControlDependency].self, forKey: .sourceControl) {
            guard let dependency = sourceControl.first else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Empty source control dependency array")
                )
            }
            self = .sourceControl(dependency)
        } else if let fileSystem = try? container.decode([FileSystemDependency].self, forKey: .fileSystem) {
            guard let dependency = fileSystem.first else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Empty file system dependency array")
                )
            }
            self = .fileSystem(dependency)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown dependency type")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .sourceControl(let dependency):
            try container.encode([dependency], forKey: .sourceControl)
        case .fileSystem(let dependency):
            try container.encode([dependency], forKey: .fileSystem)
        }
    }
    
    public var identity: String {
        switch self {
        case .sourceControl(let dependency):
            return dependency.identity
        case .fileSystem(let dependency):
            return dependency.identity
        }
    }
}