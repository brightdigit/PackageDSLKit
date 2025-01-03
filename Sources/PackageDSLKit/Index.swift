//
//  Index.swift
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

import SwiftSyntax

public struct Index: Sendable, Hashable, Codable {
  public let entries: [EntryRef]
  public let dependencies: [DependencyRef]
  public let testTargets: [TestTargetRef]
  public let swiftSettings: [SwiftSettingRef]
  public let modifiers: [Modifier]
  public init(
    entries: [EntryRef],
    dependencies: [DependencyRef],
    testTargets: [TestTargetRef],
    swiftSettings: [SwiftSettingRef],
    modifiers: [Modifier]
  ) {
    self.entries = entries
    self.dependencies = dependencies
    self.testTargets = testTargets
    self.swiftSettings = swiftSettings
    self.modifiers = modifiers
  }
}

extension Index {
  internal init(
    items: [PackageIndexStrategy.Child],
    modifiers: [ModifierType: [String]]
  ) {
    var entries: [EntryRef] = []
    var dependencies: [DependencyRef] = []
    var testTargets: [TestTargetRef] = []
    var swiftSettings: [SwiftSettingRef] = []
    for item in items {
      switch item.kind {
      case .entries:
        entries.append(.init(name: item.name))
      case .dependencies:
        dependencies.append(.init(name: item.name))
      case .testTargets:
        testTargets.append(.init(name: item.name))
      case .swiftSettings:
        swiftSettings.append(.init(name: item.name))
      }
    }

    self.init(
      entries: entries,
      dependencies: dependencies,
      testTargets: testTargets,
      swiftSettings: swiftSettings,
      modifiers: modifiers.map(Modifier.init)
    )
  }
}
