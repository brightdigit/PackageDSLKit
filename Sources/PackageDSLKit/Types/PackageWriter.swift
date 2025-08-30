//
//  PackageWriter.swift
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
import SyntaxKit

/// A writer that generates complete package structures from specifications
///
/// This struct handles the complete process of writing package files,
/// including index files and component source files, using various
/// specialized writers and file interfaces.
public struct PackageWriter: Sendable {
  private static let compoenentTypes: [any ComponentBuildable.Type] = [
    Product.self,
    Dependency.self,
    Target.self,
    TestTarget.self,
    SupportedPlatformSet.self,
  ]

  private let fileInterfaceType: PackageFilesInterfaceType
  private let fileAccessor: any PackageFilesFactory
  private let indexWriter: any IndexCodeWriter
  private let componentWriter: any StructureWriter

  /// Creates a new package writer with default components
  public init() {
    self.init(componentWriter: ComponentWriter())
  }
  internal init(
    fileAccessor: any PackageFilesFactory = PackageFiles.default,
    fileInterfaceType: PackageFilesInterfaceType = .fileManager,
    indexWriter: any IndexCodeWriter = PackageIndexWriter(),
    componentWriter: any StructureWriter
  ) {
    self.fileAccessor = fileAccessor
    self.fileInterfaceType = fileInterfaceType
    self.indexWriter = indexWriter
    self.componentWriter = componentWriter
  }

  /// Writes a complete package structure to the specified URL
  ///
  /// - Parameters:
  ///   - specification: The package specifications to write
  ///   - url: The destination URL where the package should be created
  ///
  /// - Throws: `PackageDSLError` if any part of the writing process fails
  public func write(
    _ specification: PackageSpecifications,
    to url: URL
  ) throws(PackageDSLError) {
    let filesInterface = self.fileAccessor.interface(for: self.fileInterfaceType)
    let configuration = PackageDirectoryConfiguration(specifications: specification)

    let indexFileURL = url.polyfill().appending(component: "Index.swift")
    do {
      try indexWriter.writeIndex(configuration.index).write(
        to: indexFileURL,
        atomically: true,
        encoding: .utf8
      )
    } catch {
      throw .other(error)
    }
    let components = configuration.createComponents()
    var directoryCreated = [URL: Void]()

    for component in components {
      let directoryURL: URL
      let componentType = Self.compoenentTypes.first(where: { component.isType(of: $0) })
      guard let componentType else {
        throw .custom("Unsupported component", component)
      }

      directoryURL = componentType.directoryURL(relativeTo: url)

      if directoryCreated[directoryURL] == nil {
        do {
          try filesInterface.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        } catch {
          throw .other(error)
        }
        directoryCreated[directoryURL] = ()
      }

      let filePath =
        directoryURL
        .polyfill()
        .appending(component: component.name)
        .appendingPathExtension("swift")
        .standardizedFileURL

      let node = componentWriter.syntaxKitNode(from: component)
      do {
        try node.trimmedDescription.write(to: filePath, atomically: true, encoding: .utf8)
      } catch {
        throw .other(error)
      }
    }
  }
}
