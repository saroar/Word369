//
//  LanguageCode.swift
//  
//
//  Created by Saroar Khandoker on 20.12.2021.
//

import Foundation

public struct LanguageCode: Codable, Hashable, Equatable {
  public var name: String
  public var nativeName: String
  public var code: String
}

extension LanguageCode {
  public static let bangla: LanguageCode = .init(name: "Bengali", nativeName: "বাংলা", code: "bd")
  public static let english: LanguageCode = .init(name: "English", nativeName: "English", code: "us")
  
  public static let list: [LanguageCode] = [
    .init(name: "Bengali", nativeName: "বাংলা", code: "bd"),
    .init(name: "Russian", nativeName: "русский язык", code: "ru"),
    .init(name: "English", nativeName: "English", code: "us")
  ]
}
