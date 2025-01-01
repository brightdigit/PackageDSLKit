//
//  PackageParser.swift
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

import Foundation
import SwiftParser

//
// public struct SwiftSetting : Hashable {
//  let typeName : String
// }

extension SupportedPlatform {
  init?(string: String) {
    // Remove any whitespace and optional "SupportedPlatform." prefix
    let cleanString = string.trimmingCharacters(in: .whitespaces)
      .replacingOccurrences(of: "SupportedPlatform.", with: "")

    // Split into platform and version parts
    // Example: "macOS(.v14)" -> ["macOS", "v14"]
    guard let platformRange = cleanString.range(of: "("),
      let versionEndRange = cleanString.range(of: ")", options: .backwards)
    else {
      return nil
    }

    let osName = String(cleanString[..<platformRange.lowerBound])

    // Extract version number
    let versionString = cleanString[platformRange.upperBound..<versionEndRange.lowerBound]
      .trimmingCharacters(in: .whitespaces)
      .replacingOccurrences(of: ".v", with: "")

    guard let version = Int(versionString) else {
      return nil
    }

    self.init(osName: osName, version: version)
  }
}

extension Product: ComponentBuildable {
  init?(component: Component) {
    guard component.inheritedTypes.contains("Product") else {
      return nil
    }
    let dependencies =
      component.properties["dependencies"]?.code.map { line in
        DependencyRef(
          name: line.filter({ character in
            character.isLetter || character.isNumber
          }))
      } ?? []
    let name = component.properties["name"]?.code.first
    let productType = component.properties["productType"]?.code.compactMap(
      ProductType.init(rawValue:)
    ).first

    self.init(
      typeName: component.name,
      name: name,
      dependencies: dependencies,
      productType: productType
    )
  }

  func createComponent() -> Component {
    return .init(
      name: typeName,
      inheritedTypes: ["Product", "Target"],
      properties: [
        "name" : .init(name: "name", type: "String", code: [name]),
        "dependencies" : .init(name: "dependencies", type: "any Dependencies", code: dependencies.map{$0.asFunctionCall()}),
        "productType" : .init(name: "productType", type: "ProductType", code: [productType.map{
          ".\($0.rawValue)"
        }])
      ].compactMapValues { $0 }

    )
  }
}

extension Dependency: ComponentBuildable {
  init?(component: Component) {
    let package =
      (component.properties["dependencies"]?.code.first?.filter({ character in
        character.isLetter || character.isNumber
      })).map(DependencyRef.init)
    guard let dependencyType = DependencyType(strings: component.inheritedTypes) else {
      return nil
    }
    guard dependencyType.rawValue > 0 else {
      return nil
    }
    self.init(
      typeName: component.name,
      type: dependencyType,
      dependency: component.properties["dependency"]?.code.first,
      package: package
    )
  }

  func createComponent() -> Component {
    var properties = [String: Property]()
    let inheritedTypes: [String]
    let name : String
    
    name = typeName
    inheritedTypes = self.type.asInheritedTypes()
    
    if let dependency {
      properties["dependency"] = Property(name: "dependency", type: "Package.Dependency", code: [dependency])
    }
    
    if let package {
      properties["package"] = Property(name: "package", type: "PackageDependency", code: [package.asFunctionCall()])
    }
    
    return .init(name: name, inheritedTypes: inheritedTypes, properties: properties)
  }
}
//
extension Target: ComponentBuildable {
  init?(component: Component) {
    guard component.inheritedTypes.contains("Target") else {
      return nil
    }
    let dependencies =
      component.properties["dependencies"]?.code.map { line in
        DependencyRef(
          name: line.filter({ character in
            character.isLetter || character.isNumber
          }))
      } ?? []
    self.init(typeName: component.name, dependencies: dependencies)
  }

  func createComponent() -> Component {
    
    return .init(
      name: self.typeName,
      inheritedTypes: ["Target"],
      properties:  ["dependencies" : .init(name: "dependencies", type: "any Dependencies", code: dependencies.map{$0.asFunctionCall()})]
    )
  }
}
//
extension TestTarget: ComponentBuildable {
  init?(component: Component) {
    guard component.inheritedTypes.contains("TestTarget") else {
      return nil
    }
    let dependencies =
      component.properties["dependencies"]?.code.map { line in
        DependencyRef(
          name: line.filter({ character in
            character.isLetter || character.isNumber
          }))
      } ?? []
    self.init(typeName: component.name, dependencies: dependencies)
  }

  func createComponent() -> Component {
    
    return .init(
      name: self.typeName,
      inheritedTypes: ["TestTarget"],
      properties:  ["dependencies" : .init(name: "dependencies", type: "any Dependencies", code: dependencies.map{$0.asFunctionCall()})]
    )
  }
}
//

// TODO: need to create a new type
extension Set: ComponentBuildable where Element == SupportedPlatform {
  init?(component: Component) {
    guard component.inheritedTypes.contains("PlatformSet") else {
      return nil
    }
    guard let body = component.properties["body"] else {
      return nil
    }
    guard
      body.type.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        == "any SupportedPlatforms"
    else {
      return nil
    }
    guard !body.code.isEmpty else {
      return nil
    }
    let platformValues = body.code.map(SupportedPlatform.init)
    let platforms = platformValues.compactMap { $0 }
    assert(platforms.count == platformValues.count)
    self.init(platforms)
    //            ?.code, !body.isEmpty else {
    //      return nil
    //    }
  }

  func createComponent() -> Component {
    fatalError()
  }
}
//
// extension Set : ComponentBuildable where Element == SwiftSetting {
//
// }

public struct PackageParser {
  public init() {
  }
  private func parseResults(at directoryURL: URL, with fileManager: FileManager)
    throws(PackageDSLError)
    -> [ParsingResult]
  {
    guard let enumerator = fileManager.enumerator(atPath: directoryURL.standardizedFileURL.path())
    else {
      throw .custom("Missing Enumerator at \(directoryURL)", nil)
    }
    var results = [ParsingResult]()
    while let filePath = enumerator.nextObject() as? String {
      guard filePath.hasSuffix(".swift") else {
        continue
      }
      let sourceCode: String
      do {
        sourceCode = try String(contentsOf: directoryURL.appending(path: filePath))
      } catch {
        throw .other(error)
      }
      let sourceSyntax = Parser.parse(source: sourceCode)
      let packageVisitor = PackageVisitor()
      results.append(contentsOf: packageVisitor.parse(sourceSyntax))
    }
    return results
  }
  public func parse(at directoryURL: URL, with fileManager: FileManager) throws(PackageDSLError)
    -> PackageSpecifications
  {
    let results = try parseResults(at: directoryURL, with: fileManager)

    let directoryConfiguration = try PackageDirectoryConfiguration(from: results)

    return try .init(from: directoryConfiguration)
  }
}
