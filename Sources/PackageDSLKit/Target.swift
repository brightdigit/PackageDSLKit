//
//  Target.swift
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

public struct Target: TypeSource {
  public let typeName: String
  public let dependencies: [DependencyRef]
  
  public init(typeName: String, dependencies: [DependencyRef] = []) {
    self.typeName = typeName
    self.dependencies = dependencies
  }
}

import SwiftPackageManagerKit

extension Target {
  /// Initialize Target from SPM data (for regular and executable targets)
  public init?(spmTarget: SPMTarget) {
    // Only convert regular and executable targets, skip test targets
    guard spmTarget.type == .regular || spmTarget.type == .executable else {
      return nil
    }
    
    // Convert dependencies
    let dependencies: [DependencyRef] = spmTarget.dependencies.compactMap { dependency in
      switch dependency {
      case .byName(let name, _):
        return DependencyRef(name: name)
      case .product(let productName, _, _):
        return DependencyRef(name: productName)
      }
    }
    
    self.init(
      typeName: spmTarget.name,
      dependencies: dependencies
    )
  }
}
