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
  
  public var description: String {
    return "\(countryFlag(countryCode: code.uppercased())) \(nativeName.capitalized)"
  }
  
  func countryFlag(countryCode: String) -> String {
    let base = 127397
    var tempScalarView = String.UnicodeScalarView()
    for i in countryCode.utf16 {
      if let scalar = UnicodeScalar(base + Int(i)) {
        tempScalarView.append(scalar)
      }
    }
    return String(tempScalarView)
  }
}

extension LanguageCode {
  public static let bangla: LanguageCode = .init(name: "Bangla", nativeName: "বাংলা", code: "bd")
  public static let english: LanguageCode = .init(name: "English", nativeName: "English", code: "us")
    
    public static let empty: LanguageCode = .init(name: "", nativeName: "", code: "")
    
  public static let list: [LanguageCode] = [
    .init(name: "Bangla", nativeName: "বাংলা", code: "bd"),
    .init(name: "Russian", nativeName: "русский язык", code: "ru"),
    .init(name: "English", nativeName: "English", code: "us")
  ]
}
