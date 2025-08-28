//
//  VersionRequirement.swift
//  MistKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

public import Foundation

/// Represents version requirements for dependencies
public enum VersionRequirement: Sendable, Hashable, Codable {
  case from(String)
  case upToNextMajor(from: String)
  case upToNextMinor(from: String)
  case range(from: String, to: String)
  case exact(String)
  case revision(String)
  case branch(String)

  /// Convert to SPM-compatible string representation
  internal func asSPMString() -> String {
    switch self {
    case .from(let version):
      return "from: \"\(version)\""
    case .upToNextMajor(let version):
      return ".upToNextMajor(from: \"\(version)\")"
    case .upToNextMinor(let version):
      return ".upToNextMinor(from: \"\(version)\")"
    case .range(let from, let to):
      return "\"\(from)\"..<\"\(to)\""
    case .exact(let version):
      return "exact: \"\(version)\""
    case .revision(let revision):
      return "revision: \"\(revision)\""
    case .branch(let branch):
      return "branch: \"\(branch)\""
    }
  }

  /// Parse a version requirement from a string
  /// - Parameter string: String representation of version requirement
  /// - Returns: Parsed VersionRequirement or nil if invalid
  public static func parse(_ string: String) -> VersionRequirement? {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

    // Check for range (..<)
    if trimmed.contains("..<") {
      let components = trimmed.components(separatedBy: "..<")
      guard components.count == 2 else { return nil }
      let from = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
      let to = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
      return .range(from: from, to: to)
    }

    // Check for exact version
    if trimmed.hasPrefix("exact:") {
      let version = trimmed.dropFirst(6).trimmingCharacters(in: CharacterSet(charactersIn: " \""))
      return .exact(version)
    }

    // Check for revision
    if trimmed.hasPrefix("revision:") {
      let revision = trimmed.dropFirst(9).trimmingCharacters(in: CharacterSet(charactersIn: " \""))
      return .revision(revision)
    }

    // Check for branch
    if trimmed.hasPrefix("branch:") {
      let branch = trimmed.dropFirst(7).trimmingCharacters(in: CharacterSet(charactersIn: " \""))
      return .branch(branch)
    }

    // Check for from version
    if trimmed.hasPrefix("from:") {
      let version = trimmed.dropFirst(5).trimmingCharacters(in: CharacterSet(charactersIn: " \""))
      return .from(version)
    }

    // Default to from version for plain version strings
    if isValidVersionString(trimmed) {
      return .from(trimmed)
    }

    return nil
  }

  /// Validate if a string is a valid semantic version
  private static func isValidVersionString(_ string: String) -> Bool {
    let versionPattern = #"^\d+\.\d+\.\d+(-[a-zA-Z0-9\.-]+)?(\+[a-zA-Z0-9\.-]+)?$"#
    return string.range(of: versionPattern, options: .regularExpression) != nil
  }
}
