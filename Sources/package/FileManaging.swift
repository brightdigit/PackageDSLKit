//
//  FileManaging.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/2/25.
//

import PackageDSLKit
import Foundation

internal protocol FileManaging {
  var fileManagerType: FileManagerType { get }
}

extension FileManaging {
  internal var fileManager: FileManager {
    FileManager.default
  }
}
