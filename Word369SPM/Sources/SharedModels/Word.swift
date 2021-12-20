//
//  Word.swift
//  
//
//  Created by Saroar Khandoker on 26.11.2021.
//

import Foundation

public enum WordLavel: String, Equatable, Codable {
  case beginner = "Beginner"
  case intermediate = "Intermediate"
  case advanced = "Advanced"
}

public struct Word: Equatable, Identifiable, Codable {

  public var id: String
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

  public let level: WordLavel

  public var createdAt: Date?
  public var updatedAt: Date?

  public init(
    id: String = UUID().uuidString, englishWord: String, englishDefinition: String, englishImageLink: String? = nil, englishVideoLink: String? = nil,
    russianWord: String? = nil, russianDefinition: String? = nil, russianImageLink: String? = nil, russianVideoLink: String? = nil,
    banglaWord: String? = nil, banglaDefinition: String? = nil, banglaImageLink: String? = nil, banglaVideoLink: String? = nil,
    isReadFromNotification: Bool = false,
    isReadFromView: Bool = false,
    level: WordLavel = .beginner,
    createdAt: Date? = nil,
    updatedAt: Date? = nil

  ) {
    self.id = id
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
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  public init(_ word: Word) {
    self.id = word.id
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
    self.createdAt = word.createdAt
    self.updatedAt = word.updatedAt
  }
}

public struct DayWords: Codable, Equatable {
  public init(id: Int, words: [Word] = []) {
    self.id = id
    self.words = words
  }

  public var id: Int
  public var words: [Word] = []
}
