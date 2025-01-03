//
//  PackageFilesInterface.swift
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

public protocol PackageFilesInterface {
  var currentDirectoryURL: URL { get }

  func createDirectory(
    at url: URL,
    withIntermediateDirectories createIntermediates: Bool
  ) throws

  func createFile(at url: URL, text: String)

  func swiftVersion(from directoryURL: URL) -> SwiftVersion?

  func writePackageSwiftFile(
    swiftVersion: SwiftVersion,
    from dslSourcesURL: URL,
    to pathURL: URL
  ) throws

  func createFileStructure(
    forPackageType packageType: PackageType,
    forProductName productName: String,
    at pathURL: URL
  ) throws

  func createTargetSourceAt(
    _ pathURL: URL, productName: String, _ productType: ProductType
  ) throws
}
