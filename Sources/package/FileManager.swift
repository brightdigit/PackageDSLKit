//
//  FileManager.swift
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

import Foundation

extension FileManager {
  internal func readDirectoryContents(at path: String, fileExtension: String = "swift") throws
    -> [String]
  {
    var contents: [String] = []
    let items = try contentsOfDirectory(atPath: path)

    // Process subdirectories (post-order)
    for item in items {
      let itemPath = (path as NSString).appendingPathComponent(item)
      var isDirectory: ObjCBool = false
      fileExists(atPath: itemPath, isDirectory: &isDirectory)

      if isDirectory.boolValue {
        contents += try readDirectoryContents(at: itemPath, fileExtension: fileExtension)
      }
    }

    // Process files
    for item in items where item.hasSuffix(".\(fileExtension)") {
      let itemPath = (path as NSString).appendingPathComponent(item)

      let fileContents = try String(contentsOfFile: itemPath, encoding: .utf8)
      contents.append(fileContents)
    }

    return contents
  }
}
