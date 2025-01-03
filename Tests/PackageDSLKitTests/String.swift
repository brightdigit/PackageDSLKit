//
//  String.swift
//  PackageDSLKit
//
//  Created by Leo Dion on 1/3/25.
//

extension String {
  private static let validIdentifierCharacters = Array(
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
  )

  internal static func randomIdentifier(minLength: Int = 3, maxLength: Int = 10) -> String {
    let length = Int.random(in: minLength...maxLength)
    var identifier = ""

    for _ in 0..<length {
      identifier.append(validIdentifierCharacters.randomElement()!)
    }

    return identifier
  }
}
