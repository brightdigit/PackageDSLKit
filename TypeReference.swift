//
//  TypeReference.swift
//  Lint
//
//  Created by Leo Dion on 1/1/25.
//

protocol TypeReference {
  var name: String { get }
}

public struct BasicTypeReference: TypeReference {
  public let name: String
}

public typealias EntryRef = BasicTypeReference
public typealias DependencyRef = BasicTypeReference
public typealias TestTargetRef = BasicTypeReference
public typealias SwiftSettingRef = BasicTypeReference
