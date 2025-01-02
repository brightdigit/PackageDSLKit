//
//  SupportedPlatform.swift
//  PackageDSLKit
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

public struct SupportedPlatform: Hashable {
  public let osName: String
  public let version: Int

  public func hash(into hasher: inout Hasher) {
    hasher.combine(osName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
    hasher.combine(version)
  }
}
extension SupportedPlatform {
  public var code: String {
    "SupportedPlatform.\(osName)(.v\(version)"
  }
  public init?(string: String) {
    // Remove any whitespace and optional "SupportedPlatform." prefix
    let cleanString = string.trimmingCharacters(in: .whitespaces)
      .replacingOccurrences(of: "SupportedPlatform.", with: "")

    // Split into platform and version parts
    // Example: "macOS(.v14)" -> ["macOS", "v14"]
    guard let platformRange = cleanString.range(of: "("),
      let versionEndRange = cleanString.range(of: ")", options: .backwards)
    else {
      return nil
    }

    let osName = String(cleanString[..<platformRange.lowerBound])

    // Extract version number
    let versionString = cleanString[platformRange.upperBound..<versionEndRange.lowerBound]
      .trimmingCharacters(in: .whitespaces)
      .replacingOccurrences(of: ".v", with: "")

    guard let version = Int(versionString) else {
      return nil
    }

    self.init(osName: osName, version: version)
  }
}
