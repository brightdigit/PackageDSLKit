//
//  Platform.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 8/28/25.
//

enum Platform {
  static let allowsProcess: Bool = {
    #if canImport(Foundation) && (os(macOS) || os(Linux))
      true
    #else
      false
    #endif
  }()
}
