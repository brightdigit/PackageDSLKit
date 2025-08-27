//
//  Bundle.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 8/27/25.
//

import Foundation

// MARK: - Bundle Extensions for Environment Detection

extension Bundle {
  // MARK: - Bundle Identifier Patterns

  private static let xctestPattern = "XCTest"

  /// Check if running in Xcode test bundle
  internal var isXcodeTestBundle: Bool {
    guard let bundleIdentifier = bundleIdentifier else { return false }
    return bundleIdentifier.contains(Self.xctestPattern)
  }
}
