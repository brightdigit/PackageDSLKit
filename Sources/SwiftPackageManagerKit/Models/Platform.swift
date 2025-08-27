import Foundation

/// Represents a platform requirement in a Swift package
public struct Platform: Codable, Hashable {
  public let platformName: String
  public let version: String
  public let options: [String]

  public init(platformName: String, version: String, options: [String] = []) {
    self.platformName = platformName
    self.version = version
    self.options = options
  }
}
