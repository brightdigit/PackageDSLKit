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
      // create directory in sources

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
