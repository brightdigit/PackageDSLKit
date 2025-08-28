//
//  URL.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 8/27/25.
//

import Foundation

extension URL {
  
  func polyfill () -> Polyfill {
    return Polyfill(url: self)
  }
  
  internal struct Polyfill : Sendable {
    fileprivate init(url: URL) {
      self.url = url
    }
    
    private let url : URL
    
    internal func appending(component: String, isDirectory: Bool? = nil) -> URL {
      
      if #available(iOS 16.0, *) {
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
    
    internal func path() -> String {
      if #available(iOS 16.0, *) {
        url.path()
      } else {
        url.path
      }
    }
  }
}
