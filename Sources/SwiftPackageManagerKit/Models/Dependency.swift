import Foundation

/// Represents a dependency location (remote or file system)
public enum DependencyLocation: Codable, Hashable {
    case remote(urlString: String)
    case fileSystem(path: String)
    
    private enum CodingKeys: String, CodingKey {
        case remote
        case fileSystem
    }
    
    private struct Remote: Codable {
      let urlString : String
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
      
      if container.contains(.remote) {
          let remoteArray = try container.decode([Remote].self, forKey: .remote)
          guard let remote = remoteArray.first else {
              throw DecodingError.dataCorrupted(
                  DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Empty remote array")
              )
          }
          self = .remote(urlString: remote.urlString)
      } else if container.contains(.fileSystem) {
          let fileSystemPath = try container.decode(String.self, forKey: .fileSystem)
          self = .fileSystem(path: fileSystemPath)
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
//            var remoteContainer = container.nestedContainer(keyedBy: RemoteKeys.self, forKey: .remote)
//            try remoteContainer.encode(urlString, forKey: .urlString)
          try container.encode([Remote(urlString: urlString)], forKey: .remote)
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
      
      if container.contains(.sourceControl) {
          let sourceControlArray = try container.decode([SourceControlDependency].self, forKey: .sourceControl)
          guard let dependency = sourceControlArray.first else {
              throw DecodingError.dataCorrupted(
                  DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Empty source control dependency array")
              )
          }
          self = .sourceControl(dependency)
      } else if container.contains(.fileSystem) {
          let fileSystemArray = try container.decode([FileSystemDependency].self, forKey: .fileSystem)
          guard let dependency = fileSystemArray.first else {
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
