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
            result = englishTitle
        }
        
        if from == "russian" || to == "russian" {
            result = russianTitle ?? ""
        }
        
        return result
    }
    
    public func buildNotificationDefinition(from: String, to: String) -> String {
        var result = ""
        
        if from == "english" || to == "english" {
            result = englishDefinition
        }
        
        if from == "russian" || to == "russian" {
            result = russianDefinition ?? ""
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
    
    public let russianWord: String?
    public let russianDefinition: String?
    public let russianImageLink: String?
    public let russianVideoLink: String?
    
    public let banglaWord: String?
    public let banglaDefinition: String?
    public let banglaImageLink: String?
    public let banglaVideoLink: String?
    
    public let isReadFromNotification: Bool
    public let isReadFromView: Bool
    
    public let level: WordLevel
    public let user: User?
    
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
