//
//  Word.swift
//  
//
//  Created by Saroar Khandoker on 26.11.2021.
//

import Foundation

public enum WordLevel: String, Equatable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

extension Word {
    public var englishTitle: String {
        if let iconR = icon {
            return iconR + " " + englishWord
        }
        
        return englishWord
    }
    
    public var russianTitle: String? {
        if let icon = icon, let russianWord = russianWord {
            return icon + " " + russianWord
        }
        
        return russianWord
    }
    
    public func buildNotificationTitle(from: String, to: String) -> String {
        var result = ""
        
        if from == "english" || to == "english" {
            result += englishTitle
        }
        
        if from == "russian" || to == "russian" {
            result += russianWord != nil ? " -> \(russianWord ?? "")" : ""
        }
        
        return result
    }
    
    public func buildNotificationDefinition(from: String, to: String) -> String {
        var result = ""
        
        if from == "english" || to == "english" {
            result += englishDefinition
        }
        
        if from == "russian" || to == "russian" {
            result += russianDefinition != nil ? " -> \(russianDefinition ?? "")" : ""
        }
        
        return result
    }
}

public struct Word: Equatable, Identifiable, Codable {
    
    public var id: String
    public let icon: String?
    public let englishWord: String
    public let englishDefinition: String
    public let englishImageLink: String?
    public let englishVideoLink: String?
    
    public var russianWord: String?
    public var russianDefinition: String?
    public var russianImageLink: String?
    public var russianVideoLink: String?
    
    public var banglaWord: String?
    public var banglaDefinition: String?
    public var banglaImageLink: String?
    public var banglaVideoLink: String?
    
    public var isReadFromNotification: Bool
    public var isReadFromView: Bool
    
    public var level: WordLevel
    public var user: User?
    
    public var createdAt: Date?
    public var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case icon, englishWord, englishDefinition, englishImageLink, englishVideoLink
        case russianWord, russianDefinition, russianImageLink, russianVideoLink
        case banglaWord, banglaDefinition, banglaImageLink, banglaVideoLink
        case isReadFromView, level, isReadFromNotification, user
        case createdAt, updatedAt
    }
    
    public init(
        id: String = UUID().uuidString, icon: String? = nil, englishWord: String, englishDefinition: String, englishImageLink: String? = nil, englishVideoLink: String? = nil,
        russianWord: String? = nil, russianDefinition: String? = nil, russianImageLink: String? = nil, russianVideoLink: String? = nil,
        banglaWord: String? = nil, banglaDefinition: String? = nil, banglaImageLink: String? = nil, banglaVideoLink: String? = nil,
        isReadFromNotification: Bool = false,
        isReadFromView: Bool = false,
        level: WordLevel = .beginner,
        user: User? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
        
    ) {
        self.id = id
        self.icon = icon
        self.englishWord = englishWord
        self.englishDefinition = englishDefinition
        self.englishImageLink = englishImageLink
        self.englishVideoLink = englishVideoLink
        self.russianWord = russianWord
        self.russianDefinition = russianDefinition
        self.russianImageLink = russianImageLink
        self.russianVideoLink = russianVideoLink
        self.banglaWord = banglaWord
        self.banglaDefinition = banglaDefinition
        self.banglaImageLink = banglaImageLink
        self.banglaVideoLink = banglaVideoLink
        self.isReadFromNotification = isReadFromNotification
        self.isReadFromView = isReadFromView
        self.level = level
        self.user = user
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public init(_ word: Word) {
        self.id = word.id
        self.icon = word.icon
        self.englishWord = word.englishWord
        self.englishDefinition = word.englishDefinition
        self.englishImageLink = word.englishImageLink
        self.englishVideoLink = word.englishVideoLink
        self.russianWord = word.russianWord
        self.russianDefinition = word.russianDefinition
        self.russianImageLink = word.russianImageLink
        self.russianVideoLink = word.russianVideoLink
        self.banglaWord = word.banglaWord
        self.banglaDefinition = word.banglaDefinition
        self.banglaImageLink = word.banglaImageLink
        self.banglaVideoLink = word.banglaVideoLink
        self.isReadFromNotification = word.isReadFromNotification
        self.isReadFromView = word.isReadFromView
        self.level = word.level
        self.user = word.user
        self.createdAt = word.createdAt
        self.updatedAt = word.updatedAt
    }
}

extension Word: Hashable {
    public static func == (lhs: Word, rhs: Word) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct DayWords: Codable, Equatable, Identifiable {
    public var id: String { return "\(dayNumber)" }
    public var dayNumber: Int
    public var words: [Word] = []
    
    public init(dayNumber: Int, words: [Word] = []) {
        self.dayNumber = dayNumber
        self.words = words
    }
}

public struct User: Codable, Equatable {
    public let fullName, language, id, role: String
}

extension User {
    public static var demo: User = .init(fullName: "Saroar", language: "ru", id: "624c31898addf0419b877915", role: "superAdmin")
}

extension Word {
    public static let mockEmpty: Word = .init(englishWord: "", englishDefinition: "")
    public static let mockDatas: [Word] = [
        Word(
            id: UUID().uuidString, icon: "🍏", englishWord: "Apple", englishDefinition: "AppleAppleAppleAppleAppleApple", englishImageLink: nil, englishVideoLink: nil,
            
            russianWord: "Яблока", russianDefinition: "ЯблокаЯблокаЯблокаЯблокаЯблокаЯблока", russianImageLink: nil, russianVideoLink: nil,
            
            banglaWord: "অ্যাপল", banglaDefinition: "অ্যাপলঅ্যাপলঅ্যাপলঅ্যাপল", banglaImageLink: nil, banglaVideoLink: nil,
            
            isReadFromNotification: false, isReadFromView: false, level: .beginner, user: nil, createdAt: nil, updatedAt: nil
        ),
        
        Word(
            id: UUID().uuidString, icon: "🧰", englishWord: "Able", englishDefinition: "AbleAbleAbleAbleAbleAble", englishImageLink: nil, englishVideoLink: nil,
            
            russianWord: "Способный", russianDefinition: "СпособныйСпособныйСпособныйСпособныйСпособный", russianImageLink: nil, russianVideoLink: nil,
            
            banglaWord: "সক্ষম", banglaDefinition: "সক্ষমসক্ষমসক্ষমসক্ষমসক্ষমসক্ষম", banglaImageLink: nil, banglaVideoLink: nil,
            
            isReadFromNotification: false, isReadFromView: false, level: .beginner, user: nil, createdAt: nil, updatedAt: nil
        ),
        
        Word(
            id: UUID().uuidString, icon: "💨", englishWord: "Air", englishDefinition: "AirAirAirAirAirAir", englishImageLink: nil, englishVideoLink: nil,
            
            russianWord: "Воздух", russianDefinition: "ВоздухВоздухВоздухВоздух", russianImageLink: nil, russianVideoLink: nil,
            
            banglaWord: "এয়ার", banglaDefinition: "এয়ারএয়ারএয়ারএয়ারএয়ার", banglaImageLink: nil, banglaVideoLink: nil,
            
            isReadFromNotification: false, isReadFromView: false, level: .beginner, user: nil, createdAt: nil, updatedAt: nil
        )
    ]
}
