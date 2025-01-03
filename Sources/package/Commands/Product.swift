//
//  Product.swift
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
import PackageDSLKit

extension Package {
  struct Product: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
      subcommands: [Add.self]
    )
  }
}
extension Package.Product {
  struct Add: ParsableCommand {
    @Argument var name: String

    @OptionGroup var settings: Settings

    @Option var type: ProductType = .library

    func run() throws {
      let parser = PackageParser()
      let package = try parser.parse(at: settings.dslSourcesURL, with: .default)
      let newPackage = package.updating(descriptor: Product.self) { products in
        var newProducts = products
        newProducts.append(.init(typeName: name))
        return newProducts
      }
      let writer = PackageWriter()
      try writer.write(newPackage, to: self.settings.dslSourcesURL)

      print("Written to:", "\(self.settings.pathURL.standardizedFileURL.path())")

      if let swiftVersion = self.settings.fileManager.swiftVersion(from: self.settings.pathURL) {
        try self.settings.fileManager.writePackageSwiftFile(
          swiftVersion: swiftVersion, from: self.settings.dslSourcesURL, to: self.settings.pathURL)
      }

      try! settings.fileManager.createTargetSourceAt(self.settings.pathURL, productName: name, type)
    }
  }

  struct Remove: ParsableCommand {
  }
}
