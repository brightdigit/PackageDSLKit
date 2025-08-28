//
//  URL.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 8/27/25.
//

package import Foundation

extension URL {
  package func polyfill() -> Polyfill {
    Polyfill(url: self)
  }

  package struct Polyfill: Sendable {
    fileprivate init(url: URL) {
      self.url = url
    }

    private let url: URL

    package func appending(component: String, isDirectory: Bool? = nil) -> URL {
      if #available(iOS 16.0, watchOS 9.0, tvOS 16.0, macOS 13.0, *) {
        switch isDirectory {
        case .none:
          return url.appending(component: component)
        case .some(false):
          return url.appending(component: component, directoryHint: .notDirectory)
        case .some(true):
          return url.appending(component: component, directoryHint: .isDirectory)
        }
      } else {
        if let isDirectory {
          return url.appendingPathComponent(component, isDirectory: isDirectory)
        } else {
          return url.appendingPathComponent(component)
        }
      }
    }

    package func path() -> String {
      if #available(iOS 16.0, watchOS 9.0, tvOS 16.0, macOS 13.0, *) {
        url.path()
      } else {
        url.path
      }
    }
  }
}
