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
    let dependencyType: DependencyType?
    let invalidValueError: DependencyType.InvalidValueError?
    do {
      dependencyType = try DependencyType(stringsThrows: value.strings)
      invalidValueError = nil
    } catch {
      invalidValueError = error
      dependencyType = nil
    }

    let actualResult: Result<DependencyType?, DependencyType.InvalidValueError>
    if let invalidValueError {
      actualResult = .failure(invalidValueError)
    } else {
      actualResult = .success(dependencyType)
    }

    switch (value.expectedRawValue, actualResult) {
    case let (.invalid(expected), .failure(error)):
      #expect(error.invalidCount == expected)
    case (.none, .success(.none)):
      break
    case let (.rawValue(expectedRawValue), .success(.some(actual))):
      #expect(actual.rawValue == expectedRawValue)
    default:
      Issue.record("Result mismatch: \(value.expectedRawValue) != \(actualResult)")
    }
  }
}
