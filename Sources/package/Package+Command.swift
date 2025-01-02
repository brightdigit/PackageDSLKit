//
//  Package+Command.swift
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

import ArgumentParser
import Foundation
import PackageDSLKit

extension FileManager {
  func readDirectoryContents(at path: String, fileExtension: String = "swift") throws -> [String] {
    var contents: [String] = []
    let items = try contentsOfDirectory(atPath: path)

    // Process subdirectories (post-order)
    for item in items {
      let itemPath = (path as NSString).appendingPathComponent(item)
      var isDirectory: ObjCBool = false
      fileExists(atPath: itemPath, isDirectory: &isDirectory)

      if isDirectory.boolValue {
        contents += try readDirectoryContents(at: itemPath, fileExtension: fileExtension)
      }
    }

    // Process files
    for item in items where item.hasSuffix(".\(fileExtension)") {
      let itemPath = (path as NSString).appendingPathComponent(item)
      let fileContents = try String(contentsOfFile: itemPath, encoding: .utf8)
      contents.append(fileContents)
    }

    return contents
  }
}

// Usage

// package init
// package target add "name" --product ""
// package product add "name"
// package dependnecy add "name" "giturl" --with-target
// package dependency add "name" --target ""/--product ""/--product ""
// package test add "name"

@main
struct Package: ParsableCommand {
  static let configuration: CommandConfiguration = .init(
    subcommands: [Initialize.self, Dump.self]
  )
}

protocol FileManaging {
  var fileManagerType: FileManagerType { get }
}

extension FileManaging {
  var fileManager: FileManager {
    FileManager.default
  }
}

extension Package {
  struct Dump: ParsableCommand {
    @OptionGroup var settings: Settings
    func run() throws {
      print(settings.dslSourcesURL)
      let parser = PackageParser()
      let package = try parser.parse(at: settings.dslSourcesURL, with: .default)
      dump(package)
    }
  }
}
extension Package {
  struct Initialize: ParsableCommand {
    @OptionGroup var settings: Settings

    @Option
    var name: String?

    @Option
    var swiftVersion: String?

    var packageName: String {
      self.name ?? self.settings.pathURL.lastPathComponent
    }

    var shouldCreateDirectory: Bool {
      self.settings.path != nil
    }

    static let configuration: CommandConfiguration = .init(
      commandName: "init"
    )

    func run() throws {
      if shouldCreateDirectory {
        try self.settings.fileManager.createDirectory(
          at: self.settings.dslSourcesURL, withIntermediateDirectories: true, attributes: nil)
      }

      let spec = PackageSpecifications(
        products: [
          .init(typeName: "ProductA", dependencies: [DependencyRef(name: "Vapor")])
        ],
        dependencies: [
          PackageDSLKit.Dependency(
            typeName: "Vapor", type: [.package, .target],
            dependency: ".package(url: \"https://github.com/vapor/vapor.git\", from: \"4.50.0\")",
            package: nil)
        ])
      let writer = PackageWriter()
      try writer.write(spec, to: self.settings.dslSourcesURL)
      print("Written to:", "\(self.settings.pathURL.standardizedFileURL.path())")

      // swiftlint:disable:next force_try
      let contents = try! settings.fileManager.readDirectoryContents(
        at: self.settings.pathURL.path(),
        fileExtension: "swift"
      )

      // Bundle.module
      guard let exportPathURL = settings.exportPathURL else { return }
      try? settings.fileManager.createDirectory(
        at: exportPathURL, withIntermediateDirectories: true, attributes: nil)
      let packageFileURL = exportPathURL.appendingPathComponent("Package.swift")
      let strings =
        [
          "// swift-tools-version: 6.0",
          SupportCodeBlock.syntaxNode.trimmedDescription,
        ] + contents
      let data = strings.joined(separator: "\n").data(using: .utf8)!
      settings.fileManager.createFile(atPath: packageFileURL.path(), contents: data)
      print(exportPathURL)
    }
  }
}

extension Package {
  struct Target: ParsableCommand {
  }
}

extension Package.Target {
  struct Add: ParsableCommand {
  }
}

extension Package.Target {
  struct Remove: ParsableCommand {
  }
}

extension Package {
  struct Product: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
      subcommands: [Add.self]
    )
  }
}
extension ProductType: ExpressibleByArgument {
}
extension FileManagerType: ExpressibleByArgument {
}
extension Package.Product {
  struct Add: ParsableCommand {
    @Argument var name: String

    @OptionGroup var settings: Settings

    @Option var type: ProductType = .library

    func run() throws {
      // add to products directory
      // add to index

    }
  }
}

extension Package.Product {
  struct Remove: ParsableCommand {
  }
}

extension Package {
  struct Dependency: ParsableCommand {
  }
}
extension Package.Dependency {
  struct Add: ParsableCommand {
  }
}

extension Package.Dependency {
  struct Remove: ParsableCommand {
  }
}

extension Package {
  struct Test: ParsableCommand {
  }
}

extension Package.Test {
  struct Add: ParsableCommand {
  }
}

extension Package.Test {
  struct Remove: ParsableCommand {
  }
}
