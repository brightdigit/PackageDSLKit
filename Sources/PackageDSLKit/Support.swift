//
//  Untitled.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/2/25.
//

import Foundation
import SwiftSyntax

public struct Support {
  public let syntax: SourceFileSyntax
  public init () {
    let url = Bundle.module.url(forResource: "PackageDSL", withExtension: "lz4")!
    let data = try! Data(contentsOf: url)
    let decompressed = try! (data as NSData).decompressed(using: .lz4)
    let text = String(decoding: decompressed, as: UTF8.self)
    self.syntax = SourceFileSyntax(stringLiteral: text)
    
//
//    print(syntax.trimmed(matching: { piece in
//      piece.isWhitespace || piece.isComment || piece.isSpaceOrTab
//    }))
  }
}
