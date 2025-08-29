//
//  URL.swift
//  MistKit
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

package import Foundation

extension URL {
  package struct Polyfill: Sendable {
    private let url: URL

    fileprivate init(url: URL) {
      self.url = url
    }

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
  package func polyfill() -> Polyfill {
    Polyfill(url: self)
  }
}
