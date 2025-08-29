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

internal import Foundation

/// Represents version requirements for dependencies
public enum VersionRequirement: Sendable, Hashable, Codable {
  case from(String)
  case upToNextMajor(from: String)
  case upToNextMinor(from: String)
  case range(from: String, to: String)
  case exact(String)
  case revision(String)
  case branch(String)

  // MARK: - Type Methods

  /// Parse a version requirement from a string
  /// - Parameter string: String representation of version requirement
  /// - Returns: Parsed VersionRequirement or nil if invalid
  public static func parse(_ string: String) -> VersionRequirement? {
    let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

    return parseRange(from: trimmed) ?? parseExact(from: trimmed) ?? parseRevision(from: trimmed)
      ?? parseBranch(from: trimmed) ?? parseFrom(from: trimmed)
      ?? parseDefaultVersion(from: trimmed)
  }

  private static func parseRange(from trimmed: String) -> VersionRequirement? {
    guard trimmed.contains("..<") else { return nil }
    let components = trimmed.components(separatedBy: "..<")
    guard components.count == 2 else { return nil }
    let from = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    let to = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    return .range(from: from, to: to)
  }

  private static func parseExact(from trimmed: String) -> VersionRequirement? {
    guard trimmed.hasPrefix("exact:") else { return nil }
    let version = trimmed.dropFirst(6).trimmingCharacters(in: CharacterSet(charactersIn: " \""))
    return .exact(version)
  }

  private static func parseRevision(from trimmed: String) -> VersionRequirement? {
    guard trimmed.hasPrefix("revision:") else { return nil }
    let revision = trimmed.dropFirst(9).trimmingCharacters(in: CharacterSet(charactersIn: " \""))
    return .revision(revision)
  }

  private static func parseBranch(from trimmed: String) -> VersionRequirement? {
    guard trimmed.hasPrefix("branch:") else { return nil }
    let branch = trimmed.dropFirst(7).trimmingCharacters(in: CharacterSet(charactersIn: " \""))
    return .branch(branch)
  }

  private static func parseFrom(from trimmed: String) -> VersionRequirement? {
    guard trimmed.hasPrefix("from:") else { return nil }
    let version = trimmed.dropFirst(5).trimmingCharacters(in: CharacterSet(charactersIn: " \""))
    return .from(version)
  }

  private static func parseDefaultVersion(from trimmed: String) -> VersionRequirement? {
    guard isValidVersionString(trimmed) else { return nil }
    return .from(trimmed)
  }

  /// Validate if a string is a valid semantic version
  private static func isValidVersionString(_ string: String) -> Bool {
    let versionPattern = #"^\d+\.\d+\.\d+(-[a-zA-Z0-9\.-]+)?(\+[a-zA-Z0-9\.-]+)?$"#
    return string.range(of: versionPattern, options: .regularExpression) != nil
  }

  // MARK: - Instance Methods

  /// Convert to SPM-compatible string representation
  internal func asSPMString() -> String {
    switch self {
    case .from(let version):
      return formatFromVersion(version)
    case .upToNextMajor(let version):
      return formatUpToNextMajor(version)
    case .upToNextMinor(let version):
      return formatUpToNextMinor(version)
    case let .range(from, to):
      return formatRange(from: from, to: to)
    case .exact(let version):
      return formatExact(version)
    case .revision(let revision):
      return formatRevision(revision)
    case .branch(let branch):
      return formatBranch(branch)
    }
  }

  private func formatFromVersion(_ version: String) -> String {
    "from: \"\(version)\""
  }

  private func formatUpToNextMajor(_ version: String) -> String {
    ".upToNextMajor(from: \"\(version)\")"
  }

  private func formatUpToNextMinor(_ version: String) -> String {
    ".upToNextMinor(from: \"\(version)\")"
  }

  private func formatRange(from: String, to: String) -> String {
    "\"\(from)\"..<\"\(to)\""
  }

  private func formatExact(_ version: String) -> String {
    "exact: \"\(version)\""
  }

  private func formatRevision(_ revision: String) -> String {
    "revision: \"\(revision)\""
  }

  private func formatBranch(_ branch: String) -> String {
    "branch: \"\(branch)\""
  }
}
