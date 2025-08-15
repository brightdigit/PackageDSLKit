import Foundation

/// Represents product type in a Swift package
public enum SPMProductType: Codable, Hashable {
    case library(LibraryType)
    case executable
    case plugin
    
    public enum LibraryType: String, Codable, Hashable {
        case automatic
        case dynamic
        case `static`
    }
    
    private enum CodingKeys: String, CodingKey {
        case library
        case executable
        case plugin
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let libraryTypes = try? container.decode([LibraryType].self, forKey: .library) {
            let libraryType = libraryTypes.first ?? .automatic
            self = .library(libraryType)
        } else if container.contains(.executable) {
            self = .executable
        } else if container.contains(.plugin) {
            self = .plugin
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown product type")
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .library(let libraryType):
            try container.encode([libraryType], forKey: .library)
        case .executable:
            try container.encode([String](), forKey: .executable)
        case .plugin:
            try container.encode([String](), forKey: .plugin)
        }
    }
}

/// Represents a product in a Swift package
public struct SPMProduct: Codable, Hashable {
    public let name: String
    public let type: SPMProductType
    public let targets: [String]
    public let settings: [String] // Product-specific settings
    
    public init(
        name: String,
        type: SPMProductType,
        targets: [String],
        settings: [String] = []
    ) {
        self.name = name
        self.type = type
        self.targets = targets
        self.settings = settings
    }
}