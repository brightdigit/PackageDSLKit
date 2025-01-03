//
//  DependencyTypeTests.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/3/25.
//

import Testing

@testable import PackageDSLKit

internal struct DependencyTypeTests {
  internal enum ExpectedValue {
    case rawValue(Int)
    case none
    case invalid(Int)
  }

  internal struct TestRow: Sendable {
    internal let strings: [String]
    internal let expectedRawValue: ExpectedValue
  }

  @Test(arguments: [
    TestRow(
      strings: ["PackageDependency", "TargetDependency"],
      expectedRawValue: .rawValue(3)
    ),
    TestRow(
      strings: ["PackageDependency"],
      expectedRawValue: .rawValue(1)
    ),
    TestRow(
      strings: ["TargetDependency"],
      expectedRawValue: .rawValue(2)
    ),
    TestRow(
      strings: [],
      expectedRawValue: .none
    ),
    TestRow(
      strings: [String.randomIdentifier(), String.randomIdentifier()],
      expectedRawValue: .none
    ),
    TestRow(
      strings: ["PackageDependency", String.randomIdentifier()],
      expectedRawValue: .invalid(1)
    ),
  ]) internal func initializeFromStrings(_ value: TestRow) {
    let actualResult = Result {
      try Dependency.DependencyType(stringsThrows: value.strings)
    }.mapError {
      // swiftlint:disable:next force_cast
      $0 as! Dependency.DependencyType.InvalidValueError
    }

    switch (value.expectedRawValue, actualResult) {
    case (.invalid(let expected), .failure(let error)):
      #expect(error.invalidCount == expected)
    case (.none, .success(.none)):
      break
    case (.rawValue(let expectedRawValue), .success(.some(let actual))):
      #expect(actual.rawValue == expectedRawValue)
    default:
      Issue.record("Result mismatch: \(value.expectedRawValue) != \(actualResult)")
    }
  }
}
