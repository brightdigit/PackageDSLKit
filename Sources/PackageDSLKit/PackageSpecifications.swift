//
//  PackageSpecifications.swift
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

public struct PackageSpecifications: Sendable, Hashable, Codable {
  public let products: [Product]
  public let dependencies: [Dependency]
  public let targets: [Target]
  public let testTargets: [TestTarget]
  public let supportedPlatformSets: [SupportedPlatformSet]
  public let swiftSettings: [SwiftSettingRef]
  public let modifiers: [Modifier]

  public init(
    products: [Product] = [],
    dependencies: [Dependency] = [],
    targets: [Target] = [],
    testTargets: [TestTarget] = [],
    supportedPlatformSets: [SupportedPlatformSet] = [],
    swiftSettings: [SwiftSettingRef] = [],
    modifiers: [Modifier] = []
  ) {
    self.products = products
    self.dependencies = dependencies
    self.targets = targets
    self.testTargets = testTargets
    self.supportedPlatformSets = supportedPlatformSets
    self.swiftSettings = swiftSettings
    self.modifiers = modifiers
  }
}

extension PackageSpecifications {
  public init(from directoryConfiguration: PackageDirectoryConfiguration) throws(PackageDSLError) {
    try directoryConfiguration.validate()
    self.products = directoryConfiguration.products
    self.dependencies = directoryConfiguration.dependencies
    self.targets = directoryConfiguration.targets
    self.testTargets = directoryConfiguration.testTargets
    self.swiftSettings = directoryConfiguration.index.swiftSettings
    self.supportedPlatformSets = directoryConfiguration.supportedPlatformSets
    self.modifiers = directoryConfiguration.index.modifiers
  }
}

extension PackageSpecifications {
  public func updating<P: PackagePropertyDescriptor>(descriptor: P.Type, transform: ([P]) -> [P])
    -> PackageSpecifications
  {
    descriptor.update(original: self, transform: transform)
  }
}
