import Foundation

/// Represents the package kind
public enum SPMPackageKind: Codable, Hashable {
    case root(String)
    case local(String)
    case remote
    
    private enum CodingKeys: String, CodingKey {
        case root
        case local
        case remote
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let rootPaths = try? container.decode([String].self, forKey: .root) {
            let path = rootPaths.first ?? ""
            self = .root(path)
        } else if let localPaths = try? container.decode([String].self, forKey: .local) {
            let path = localPaths.first ?? ""
            self = .local(path)
        } else if container.contains(.remote) {
            self = .remote
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown package kind")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .root(let path):
            try container.encode([path], forKey: .root)
        case .local(let path):
            try container.encode([path], forKey: .local)
        case .remote:
            try container.encode([String](), forKey: .remote)
        }
    }
}

/// Represents the tools version
public struct SPMToolsVersion: Codable, Hashable {
    public let version: String
    
    private enum CodingKeys: String, CodingKey {
        case _version
    }
    
    public init(version: String) {
        self.version = version
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(String.self, forKey: ._version)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: ._version)
    }
}

/// Represents the complete package information from swift package dump-package
public struct SPMPackageInfo: Codable, Hashable {
    public let name: String
    public let packageKind: SPMPackageKind
    public let platforms: [SPMPlatform]
    public let products: [SPMProduct]
    public let dependencies: [SPMDependency]
    public let targets: [SPMTarget]
    public let toolsVersion: SPMToolsVersion
    public let traits: [String]
    public let cLanguageStandard: String?
    public let cxxLanguageStandard: String?
    public let swiftLanguageVersions: [String]?
    public let pkgConfig: String?
    public let providers: [String]?
    
    public init(
        name: String,
        packageKind: SPMPackageKind,
        platforms: [SPMPlatform] = [],
        products: [SPMProduct] = [],
        dependencies: [SPMDependency] = [],
        targets: [SPMTarget] = [],
        toolsVersion: SPMToolsVersion,
        traits: [String] = [],
        cLanguageStandard: String? = nil,
        cxxLanguageStandard: String? = nil,
        swiftLanguageVersions: [String]? = nil,
        pkgConfig: String? = nil,
        providers: [String]? = nil
    ) {
        self.name = name
        self.packageKind = packageKind
        self.platforms = platforms
        self.products = products
        self.dependencies = dependencies
        self.targets = targets
        self.toolsVersion = toolsVersion
        self.traits = traits
        self.cLanguageStandard = cLanguageStandard
        self.cxxLanguageStandard = cxxLanguageStandard
        self.swiftLanguageVersions = swiftLanguageVersions
        self.pkgConfig = pkgConfig
        self.providers = providers
    }
}