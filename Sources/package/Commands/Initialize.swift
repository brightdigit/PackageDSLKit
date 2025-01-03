//
//  Initialize.swift
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

extension Package {
  internal struct Initialize: ParsableCommand {
    @OptionGroup internal var settings: Settings

    @Option
    internal var name: String?

    @Option
    internal var swiftVersion: SwiftVersion = "6.0"

    @Option
    internal var packageType: PackageType = .empty

    internal var packageName: String {
      self.name ?? self.settings.pathURL.lastPathComponent
    }

    internal var shouldCreateDirectory: Bool {
      self.settings.path != nil
    }

    internal static let configuration: CommandConfiguration = .init(
      commandName: "init"
    )

    private var productName: String {
      name ?? settings.rootName
    }

    internal func run() throws {
      if shouldCreateDirectory {
        try self.settings.fileManager.createDirectory(
          at: self.settings.dslSourcesURL,
          withIntermediateDirectories: true,
          attributes: nil
        )
      }

      let spec = PackageSpecifications(
        name: name ?? settings.rootName,
        type: self.packageType
      )
      let writer = PackageWriter()
      try writer.write(spec, to: self.settings.dslSourcesURL)
      print("Written to:", "\(self.settings.pathURL.standardizedFileURL.path())")

      let swiftVersionFile = settings.pathURL.appending(component: ".swift-version")
      settings.fileManager.createFile(
        atPath: swiftVersionFile.path(),
        contents: Data("\(self.swiftVersion)".utf8)
      )
      try settings.fileManager.writePackageSwiftFile(
        swiftVersion: swiftVersion,
        from: settings.dslSourcesURL,
        to: settings.pathURL
      )
      print(settings.pathURL)

      try settings.fileManager.createFileStructure(
        forPackageType: packageType,
        forProductName: productName,
        at: settings.pathURL
      )
    }
  }
}
