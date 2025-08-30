//
//  PackageDirectoryConfiguration+Validation.swift
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

extension PackageDirectoryConfiguration {
  /// Creates a package directory configuration from package specifications
  ///
  /// - Parameter specifications: The package specifications to convert
  public init(specifications: PackageSpecifications) {
    let entries = specifications.products.map(EntryRef.init)
    let dependencies = specifications.dependencies.map(DependencyRef.init)
    let testTargets = specifications.testTargets.map(TestTargetRef.init)
    let swiftSettings = specifications.swiftSettings
    let index = Index(
      entries: entries,
      dependencies: dependencies,
      testTargets: testTargets,
      swiftSettings: swiftSettings,
      modifiers: specifications.modifiers
    )

    self.init(
      index: index,
      products: specifications.products,
      dependencies: specifications.dependencies,
      targets: specifications.targets,
      testTargets: specifications.testTargets,
      supportedPlatformSets: specifications.supportedPlatformSets
    )
  }
  private func validateDependencies() -> [MissingSource] {
    let dependencyNames = Set(
      self.dependencies.map {
        $0.typeName
      }
        + self.targets.map {
          $0.typeName
        }
    )

    var missingSources: [MissingSource] = []

    for product in self.products {
      let productNames = Set(
        product.dependencies.map {
          $0.name
        }
      )
      let missingDependencies = productNames.subtracting(dependencyNames)
      missingSources.append(
        contentsOf: missingDependencies.map({ dependencyName in
          MissingSource(
            source: .product(product.typeName),
            sourceType: .dependency,
            name: dependencyName
          )
        })
      )
    }

    for target in self.targets {
      let missingDependencies = Set(target.dependencies.map(\.name)).subtracting(dependencyNames)
      missingSources.append(
        contentsOf: missingDependencies.map({ dependencyName in
          MissingSource(
            source: .target(target.typeName),
            sourceType: .dependency,
            name: dependencyName
          )
        })
      )
    }
    return missingSources
  }

  /// Validates the package configuration for completeness and consistency
  ///
  /// This method checks that all referenced components exist and that there are
  /// no missing dependencies or sources that would prevent the package from building.
  ///
  /// - Throws: `PackageDSLError.validationFailure` if validation fails
  public func validate() throws(PackageDSLError) {
    var missingSources = validateDependencies()
    for sourceType in SourceType.allCases {
      missingSources.append(contentsOf: validateSourceType(sourceType: sourceType))
    }
    guard missingSources.isEmpty else {
      throw .validationFailure(missingSources)
    }
  }

  private func validateSourceType(sourceType: SourceType) -> [MissingSource] {
    let references = sourceType.indexReferences(from: self.index).map(\.name)
    let sources = sourceType.sources(from: self).map(\.typeName)
    return Set(references).subtracting(sources).map {
      MissingSource(source: .index, sourceType: sourceType, name: $0)
    }
  }
}
