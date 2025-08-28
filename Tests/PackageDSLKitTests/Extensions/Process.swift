//
//  EnvironmentDetector.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 8/27/25.
//

import Foundation

// MARK: - Process Extensions for Environment Detection

extension ProcessInfo {
  // MARK: - Environment Variable Keys

  private static let gitHubActionsKey = "GITHUB_ACTIONS"
  private static let xcodeVersionKey = "XCODE_VERSION"
  private static let xcodeProductBuildVersionKey = "XCODE_PRODUCT_BUILD_VERSION"
  private static let srcRootKey = "SRCROOT"
  private static let builtProductsDirKey = "BUILT_PRODUCTS_DIR"
  private static let configurationBuildDirKey = "CONFIGURATION_BUILD_DIR"

  // MARK: - Process Argument Patterns

  private static let xcodePattern = "Xcode"
  private static let xcodebuildPattern = "xcodebuild"

  // MARK: - Xcode Environment Variables

  private static let xcodeSpecificVars = [
    xcodeVersionKey,
    xcodeProductBuildVersionKey,
    srcRootKey,
    builtProductsDirKey,
    configurationBuildDirKey,
  ]

  /// Check if running in GitHub Actions CI
  internal var isGitHubCI: Bool {
    self.environment[Self.gitHubActionsKey] != nil
  }

  /// Check if running via Xcode (vs SPM)
  internal var isRunningViaXcode: Bool {
    hasXcodeEnvironmentVars || hasXcodeProcessArgs
  }

  /// Check if Xcode-specific environment variables are present
  private var hasXcodeEnvironmentVars: Bool {
    Self.xcodeSpecificVars.contains { self.environment[$0] != nil }
  }

  /// Check if Xcode-specific process arguments are present
  private var hasXcodeProcessArgs: Bool {
    arguments.contains {
      $0.contains(Self.xcodePattern) || $0.contains(Self.xcodebuildPattern)
    }
  }
}

// MARK: - Convenience Extensions

extension ProcessInfo {
  /// Check if SPM validation tests should be disabled
  /// - Parameter bundle: The bundle to check for Xcode test bundle
  /// - Returns: True if SPM validation should be disabled
  internal func shouldDisableSPMValidation(bundle: Bundle = .main) -> Bool {
    isGitHubCI && (isRunningViaXcode || bundle.isXcodeTestBundle)
  }
}
