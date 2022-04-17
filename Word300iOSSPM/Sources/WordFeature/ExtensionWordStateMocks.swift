//
//  File.swift
//  
//
//  Created by Saroar Khandoker on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import ComposableUserNotifications
import SharedModels
import DayWordCardsFeature

extension WordState {
  static public var wordsMock: IdentifiedArrayOf<Word> = [
    .init(
      englishWord: "Apple 1",
      englishDefinition: "Eat one apple a day keeps doctor away",
      
      russianWord: "Яблоко 1",
      russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",
      
      banglaWord: "苹果",
      banglaDefinition: "每天吃一个苹果让医生远离",
      
      isReadFromNotification: false,
      isReadFromView: false,
      user: .demo
    ),
    
      .init(
        englishWord: "Apple 2",
        englishDefinition: "Eat one apple a day keeps doctor away",
        
        russianWord: "Яблоко 2",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",
        
        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",
        
        isReadFromNotification: false,
        isReadFromView: false,
        user: .demo
      ),
    
      .init(
        englishWord: "Apple 3",
        englishDefinition: "Eat one apple a day keeps doctor away",
        
        russianWord: "Яблоко 3",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",
        
        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",
        
        isReadFromNotification: false,
        isReadFromView: false,
        user: .demo
      ),
    
      .init(
        englishWord: "Apple 4",
        englishDefinition: "Eat one apple a day keeps doctor away",
        
        russianWord: "Яблоко 4",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",
        
        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",
        
        isReadFromNotification: false,
        isReadFromView: false,
        user: .demo
      ),
    
      .init(
        englishWord: "Apple 5",
        englishDefinition: "Eat one apple a day keeps doctor away",
        
        russianWord: "Яблоко 5",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",
        
        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",
        
        isReadFromNotification: false,
        isReadFromView: false,
        user: .demo
      ),
    
      .init(
        englishWord: "Apple 6",
        englishDefinition: "Eat one apple a day keeps doctor away",
        
        russianWord: "Яблоко 6",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",
        
        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",
        
        isReadFromNotification: false,
        isReadFromView: false,
        user: .demo
      ),
    
      .init(
        englishWord: "Apple 7",
        englishDefinition: "Eat one apple a day keeps doctor away",
        
        russianWord: "Яблоко 7",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",
        
        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",
        
        isReadFromNotification: false,
        isReadFromView: false,
        user: .demo
      )
  ]
  
  static public var dayWordsMock: DayWords = .init(dayNumber: 2, words: [
    .init(
      englishWord: "Apple 7",
      englishDefinition: "Eat one apple a day keeps doctor away",
      
      russianWord: "Яблоко 7",
      russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",
      
      banglaWord: "苹果",
      banglaDefinition: "每天吃一个苹果让医生远离",
      
      isReadFromNotification: false,
      isReadFromView: false,
      user: .demo
    )
  ])
    
  static public var mock: WordState = .init(
    words: wordsMock,
    dayWordCardState: DayWordCardsState(
      dayWordCardStates: .init(uniqueElements: [.init(id: 0, word: Word(englishWord: "Apple", englishDefinition: "Apple Def", user: .demo))])
    ),
    dayWords: [dayWordsMock]
  )
}
