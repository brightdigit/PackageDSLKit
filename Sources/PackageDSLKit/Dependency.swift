//
//  Dependency.swift
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

extension Int {
  func powerOfTwoExponents() -> [Int] {
    var number = self
    var exponents: [Int] = []
    var currentExponent = 0

    while number > 0 {
      if number & 1 == 1 {
        exponents.append(currentExponent)
      }
      number >>= 1
      currentExponent += 1
    }

    return exponents
  }
}

public struct Dependency: TypeSource {
  public init(typeName: String, type: Dependency.DependencyType, dependency: String? = nil, package: DependencyRef? = nil) {
    self.typeName = typeName
    self.type = type
    self.dependency = dependency
    self.package = package
  }
  
  public let typeName: String

  public struct DependencyType: OptionSet, Sendable {
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    public var rawValue: Int

    public typealias RawValue = Int

    public static let package = DependencyType(rawValue: 1)
    public static let target = DependencyType(rawValue: 2)

    private static let strings: [String] = ["PackageDependency", "TargetDependency"]
    public init?(strings: [String]) {
      let indicies = strings.map {
        Self.strings.firstIndex(of: $0)
      }
      let rawValues = indicies.compactMap(\.self).map { $0 + 1 }
      if rawValues.isEmpty {
        return nil
      }
      assert(rawValues.count == indicies.count)
      let rawValue = rawValues.reduce(0) { $0 + $1 }
      self.init(rawValue: rawValue)
    }

    func asInheritedTypes() -> [String] {
      rawValue.powerOfTwoExponents().map { Self.strings[$0] }
    }
  }

  let type: DependencyType
  let dependency: String?
  let package: DependencyRef?
}
