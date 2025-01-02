//
//  Property.swift
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

public struct Property: Sendable {
  public let name: String
  public let type: String
  public let code: [String]
  public init(
    name: String,
    type: String,
    code: [String]
  ) {
    self.name = name
    self.type = type
    self.code = code
  }
}

extension Property {
  internal init?(name: String, type: String, code: [String?], disallowEmpty: Bool) {
    let code = code.compactMap(\.self)
    guard !code.isEmpty || !disallowEmpty else {
      return nil
    }
    self.init(name: name, type: type, code: code)
  }
}

extension Property {
  internal struct MissingFieldsError: OptionSet, Error {
    internal var rawValue: Int

    internal typealias RawValue = Int

    internal static let name = MissingFieldsError(rawValue: 1)
    internal static let type = MissingFieldsError(rawValue: 2)
    // static let code = MissingFieldsError(rawValue: 4)
  }

  internal init(name: String?, type: String?, code: [String]) throws(MissingFieldsError) {
    var error: MissingFieldsError = []
    if name == nil {
      error.insert(.name)
    }
    if type == nil {
      error.insert(.type)
    }
    if !error.isEmpty {
      throw error
    } else {
      assert(name != nil && type != nil)
      self.init(name: name ?? "", type: type ?? "", code: code)
    }
  }
}
