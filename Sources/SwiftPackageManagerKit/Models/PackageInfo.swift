//
//  PackageInfo.swift
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

import Foundation

/// Represents the complete package information from swift package dump-package
public struct PackageInfo: Codable, Hashable, Sendable {
  /// The name of the package.
  public let name: String

  /// The kind of package (local, remote, etc.).
  public let packageKind: PackageKind

  /// The platforms this package supports.
  public let platforms: [Platform]

  /// The products defined in this package.
  public let products: [Product]

  /// The dependencies of this package.
  public let dependencies: [Dependency]

  /// The targets defined in this package.
  public let targets: [Target]

  /// The Swift tools version required by this package.
  public let toolsVersion: ToolsVersion

  /// Additional traits or characteristics of this package.
  public let traits: [String]

  /// The C language standard used by this package.
  public let cLanguageStandard: String?

  /// The C++ language standard used by this package.
  public let cxxLanguageStandard: String?

  /// The Swift language versions supported by this package.
  public let swiftLanguageVersions: [String]?

  /// The pkg-config configuration for this package.
  public let pkgConfig: String?

  /// The system package providers for this package.
  public let providers: [String]?

  /// Creates a new PackageInfo instance with the specified configuration.
  ///
  /// - Parameters:
  ///   - name: The name of the package.
  ///   - packageKind: The kind of package (local, remote, etc.).
  ///   - platforms: The platforms this package supports. Defaults to an empty array.
  ///   - products: The products defined in this package. Defaults to an empty array.
  ///   - dependencies: The dependencies of this package. Defaults to an empty array.
  ///   - targets: The targets defined in this package. Defaults to an empty array.
  ///   - toolsVersion: The Swift tools version required by this package.
  ///   - traits: Additional traits or characteristics of this package. Defaults to an empty array.
  ///   - cLanguageStandard: The C language standard used by this package. Defaults to nil.
  ///   - cxxLanguageStandard: The C++ language standard used by this package. Defaults to nil.
  ///   - swiftLanguageVersions: The Swift language versions supported by this package. Defaults to nil.
  ///   - pkgConfig: The pkg-config configuration for this package. Defaults to nil.
  ///   - providers: The system package providers for this package. Defaults to nil.
  public init(
    name: String,
    packageKind: PackageKind,
    platforms: [Platform] = [],
    products: [Product] = [],
    dependencies: [Dependency] = [],
    targets: [Target] = [],
    toolsVersion: ToolsVersion,
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
