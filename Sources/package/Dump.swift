//
//  Dump.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/2/25.
//

import PackageDSLKit
import ArgumentParser

extension Package {
  internal struct Dump: ParsableCommand {
    @OptionGroup var settings: Settings
    internal func run() throws {
      print(settings.dslSourcesURL)
      let parser = PackageParser()
      let package = try parser.parse(at: settings.dslSourcesURL, with: .default)
      dump(package)
    }
  }
}
