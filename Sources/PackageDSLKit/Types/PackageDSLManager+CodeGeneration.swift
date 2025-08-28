//
//  PackageDSLManager+CodeGeneration.swift
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

public import Foundation

// MARK: - Code Generation

extension PackageDSLManager {
  /// Generate DSL component files in the package directory
  /// - Throws: PackageError on generation failures
  /// - Returns: Self for method chaining
  @discardableResult
  public func generatePackageSwift() throws(PackageError) -> PackageDSLManager {
    do {
      // Use PackageWriter to generate DSL component files
      let packageWriter = PackageWriter()
      try packageWriter.write(specifications, to: packageURL)
      return self
    } catch {
      throw PackageError.packageGenerationFailed(
        "DSL generation failed: \(error.localizedDescription)")
    }
  }

  /// Generate traditional Package.swift content from current configuration
  /// - Returns: String containing Package.swift content
  public func generateTraditionalPackageSwift() -> String {
    var content = createPackageHeader()

    content += addProductsSection()
    content += addDependenciesSection()
    content += addTargetsSection()

    content += "\n    )\n"
    return content
  }

  private func createPackageHeader() -> String {
    """
    // swift-tools-version: 5.9
    import PackageDescription

    let package = Package(
        name: "\(packageName)"
    """
  }

  private func addProductsSection() -> String {
    guard !products.isEmpty else { return "" }

    var section = ",\n        products: [\n"

    for (index, product) in products.enumerated() {
      section += createProductEntry(product, isLast: index == products.count - 1)
    }

    section += "        ]"
    return section
  }

  private func createProductEntry(_ product: Product, isLast: Bool) -> String {
    let productTargets = product.dependencies.map { "\"" + $0.name + "\"" }.joined(separator: ", ")
    let productTypeString = product.productType == .library ? "library" : "executable"

    var entry =
      "            .\(productTypeString)(name: \"\(product.typeName)\", targets: [\(productTargets)])"
    if !isLast {
      entry += ","
    }
    entry += "\n"
    return entry
  }

  private func addDependenciesSection() -> String {
    guard !dependencies.isEmpty else { return "" }

    var section = ",\n        dependencies: [\n"

    for (index, dependency) in dependencies.enumerated() {
      section += createDependencyEntry(dependency, isLast: index == dependencies.count - 1)
    }

    section += "        ]"
    return section
  }

  private func createDependencyEntry(_ dependency: Dependency, isLast: Bool) -> String {
    let dependencyString = dependency.dependency ?? ""
    let cleanDependency = cleanDependencyString(dependencyString)

    var entry = "            " + cleanDependency
    if !isLast {
      entry += ","
    }
    entry += "\n"
    return entry
  }

  private func cleanDependencyString(_ dependencyString: String) -> String {
    // Remove quotes if they exist around the dependency string
    if dependencyString.hasPrefix("\"") && dependencyString.hasSuffix("\"") {
      return String(dependencyString.dropFirst().dropLast())
    }
    return dependencyString
  }

  private func addTargetsSection() -> String {
    let allTargets =
      targets
      + testTargets.map { testTarget in
        Target(typeName: testTarget.typeName, dependencies: testTarget.dependencies)
      }

    guard !allTargets.isEmpty else { return "" }

    var section = ",\n        targets: [\n"

    for (index, target) in allTargets.enumerated() {
      section += createTargetEntry(target, isLast: index == allTargets.count - 1)
    }

    section += "        ]"
    return section
  }

  private func createTargetEntry(_ target: Target, isLast: Bool) -> String {
    let isTestTarget = testTargets.contains { $0.typeName == target.typeName }
    let targetType = isTestTarget ? "testTarget" : "target"

    var entry: String
    if target.dependencies.isEmpty {
      entry = "            .\(targetType)(name: \"\(target.typeName)\")"
    } else {
      let targetDeps = target.dependencies.map { "\"" + $0.name + "\"" }.joined(separator: ", ")
      entry =
        "            .\(targetType)(name: \"\(target.typeName)\", dependencies: [\(targetDeps)])"
    }

    if !isLast {
      entry += ","
    }
    entry += "\n"
    return entry
  }

  /// Check if the package directory has existing DSL component files
  /// - Returns: True if DSL components exist, false otherwise
  public func hasDSLComponents() -> Bool {
    let indexFile = packageURL.appendingPathComponent("Index.swift")
    return FileManager.default.fileExists(atPath: indexFile.path)
  }

  /// Check if the package directory has a traditional Package.swift file
  /// - Returns: True if Package.swift exists, false otherwise
  public func hasTraditionalPackageSwift() -> Bool {
    let packageSwiftFile = packageURL.appendingPathComponent("Package.swift")
    return FileManager.default.fileExists(atPath: packageSwiftFile.path)
  }
}
