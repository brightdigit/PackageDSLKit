import Foundation
let url = URL(filePath: "/Users/leo/Documents/Projects/PackageDSLKit/Sources/PackageDSLKit/Resources/PackageDSL")
let data = try! Data(contentsOf: url)
let compressedData = try! (data as NSData).compressed(using: .lz4)
let destination = URL(filePath: "/Users/leo/Documents/Projects/PackageDSLKit/Sources/PackageDSLKit/Resources/PackageDSL.lz4")

try! compressedData.write(to: destination)
