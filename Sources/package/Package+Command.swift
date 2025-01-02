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

struct SwiftVersion : Sendable, Equatable, ExpressibleByStringLiteral, ExpressibleByArgument {
  internal init(major: Int, minor: Int) {
    self.major = major
    self.minor = minor
  }
  init(argument value: String) {
    let components = value.components(separatedBy: ".")
    let major :Int = .init( components[0])!
    let minor :Int = .init( components[1])!
    self.init(major: major, minor: minor)
  }
  
  init(stringLiteral value: String) {
    let components = value.components(separatedBy: ".")
    let major :Int = .init( components[0])!
    let minor :Int = .init( components[1])!
    self.init(major: major, minor: minor)
  }
  
  let major : Int
  let minor : Int
}
extension Package {
  struct Initialize: ParsableCommand {
    enum PackageType : String, ExpressibleByArgument{
      case empty
      case library
      case executable
    }
    
    @OptionGroup var settings: Settings

    @Option
    var name: String?

    @Option
    var swiftVersion: SwiftVersion = "6.0"
    
    @Option
    var packageType: PackageType = .empty

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

      let spec = PackageSpecifications(name: name ?? settings.rootName, type: self.packageType)
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
          "// swift-tools-version: \(self.swiftVersion)",

          SupportCodeBlock.syntaxNode.trimmedDescription,
        ] + contents
      let data = strings.joined(separator: "\n").data(using: .utf8)!
      settings.fileManager.createFile(atPath: packageFileURL.path(), contents: data)
      print(exportPathURL)
      // TODO: Added Other Nessecary Files (Sources, Tests, etc...)
    }
  }
}

extension Package {
  struct Target: ParsableCommand {
  }
}

extension Package.Target {
  struct Add: ParsableCommand {
    @Argument var name: String
    
    @OptionGroup var settings: Settings
    
    
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
