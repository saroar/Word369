//
//  WordState.swift
//  
//
//  Created by Saroar Khandoker on 24.12.2021.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import ComposableUserNotifications
import SharedModels
import HTTPRequestKit
import WordClient
import Combine
import DayWordCardsFeature
import DayWordCardFeature
import SettingsFeature

public struct WordState: Equatable {
  
  public var words: IdentifiedArrayOf<Word> = []
  public var todayWords: IdentifiedArrayOf<Word> = []
  public var dayWordCardState: DayWordCardsState
  public var settingsState: SettingsState?
  public var isSettingsNavigationActive: Bool { self.settingsState != nil }
  public var dayWords: [DayWords] = []
  public var currentHour = Calendar.current.component(.hour, from: Date())
  public var currentDay: Int = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
  public var startHour: Int = 9
  public var endHour: Int = 20
  public var currentDate = Date().get(.day, .month, .year)
  public var hourIndx = 0
  public var dateComponents = DateComponents()
  public var isLoading = false
    
  public var from = UserDefaults.currentLanguage.name.lowercased()
  public var to = UserDefaults.learnLanguage.name.lowercased()
  
  public init(
    words: IdentifiedArrayOf<Word> = [],
    todayWords: IdentifiedArrayOf<Word> = [],
    dayWordCardState: DayWordCardsState ,
    dayWords: [DayWords] = []
  ) {
    self.words = words
    self.todayWords = todayWords
    self.dayWordCardState = dayWordCardState
    self.dayWords = dayWords
  }
}

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
  ]
  )
  static public var mock: WordState = .init(
    words: wordsMock,
    dayWordCardState: DayWordCardsState(
      dayWordCardStates: .init(uniqueElements: [.init(id: 0, word: Word(englishWord: "Apple", englishDefinition: "Apple Def", user: .demo))])
    ),
    dayWords: [dayWordsMock]
  )
}

extension WordState {
  mutating func buildDayWords(words: [Word]) -> [DayWords] {
    
    dayWords.append(DayWords(dayNumber: self.currentDay))
    
    var hourIndex = self.hourIndx
    var currentHour = self.currentHour
    let startHour = self.startHour
    let endHour = self.endHour
    var currentDay = self.currentDay
    
    var startNextHourFromCurrent = currentHour + 1
    
    /// if current hour bigther or eqal
    if currentHour >= endHour {
      currentDay += 1
      currentHour = startHour
    }
    
    for word in words {
      let fromDayStartHourToEndHours = (startNextHourFromCurrent...endHour)
      debugPrint(fromDayStartHourToEndHours.map { $0} )
      if hourIndex == fromDayStartHourToEndHours.count {
        hourIndex = 0
        // when 1st day is finished
        // start 2nd dayHours from 0 -> how i can start 2nd day here
        startNextHourFromCurrent = startHour - 1 // set start hour from currentNextHour
        
        currentDay += 1
      }
      
      if let row = dayWords.firstIndex(where: { $0.dayNumber == currentDay }) {
        dayWords[row].words.append(Word(word))
      } else {
        dayWords.append(DayWords(dayNumber: currentDay, words: [Word(word)]))
      }
      
      hourIndex += 1
      
    }
    
    if let row = dayWords.firstIndex(where: { $0.dayNumber == self.currentDay }) {
      self.todayWords = .init(uniqueElements: dayWords[row].words)
      let cardState: IdentifiedArrayOf<DayWordCardState> = .init(
        uniqueElements: dayWords[row].words
          .enumerated()
          .map { idx, word in
            DayWordCardState.init(id: idx, word: word)
        }
      )
      self.dayWordCardState = .init(dayWordCardStates: cardState )
    }
    
    UserDefaults.dayWords = dayWords
    return dayWords
  }
  
  mutating func buildDayWordsEffect(words: [Word]) -> Effect<[DayWords], Never> {
    Effect(value: self.buildDayWords(words: words))
  }
  
  mutating func buildDayWordsEffectResult(words: [Word]) -> Effect<WordAction, Never> {
    Effect(value: .receiveDayWords(.success(self.buildDayWords(words: words))))
  }
}

extension WordState {
  mutating func buildNotificationRequests(words: [Word]) -> [UNNotificationRequest] {
    
    var hourIndex = self.hourIndx
    var currentHour = self.currentHour
    let startHour = self.startHour
    let endHour = self.endHour
    var currentDay = self.currentDay
    
    /// if current hour bigther or eqal
    if currentHour >= endHour {
      dateComponents.day! += 1
      currentHour = startHour
    }
    
    var currentHourNext = currentHour + 1
    var requests: [UNNotificationRequest] = []
    
    debugPrint(#line, "Start", requests.count)
    
    for word in words {
      
      let fromDayStartHourToEndHours = (currentHourNext...endHour).map { $0 }
      
      // 1st day start from 9 to 20
      if hourIndex == fromDayStartHourToEndHours.count {
        hourIndex = 0
        // when 1st day is finished
        // start 2nd dayHours from 0 -> how i can start 2nd day here
        currentHourNext = startHour - 1 // set start hour from currentNextHour
        currentDay += 1
      }
      
      dateComponents.hour = fromDayStartHourToEndHours[hourIndex]
      let content = UNMutableNotificationContent()
      content.title = word.buildNotificationTitle(from: from, to: to)
      content.body = word.buildNotificationDefinition(from: from, to: to)
      content.categoryIdentifier = "com.addame.words300"
      content.sound = UNNotificationSound.default
      
      let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      let request = UNNotificationRequest(identifier: word.id, content: content, trigger: trigger)
      
      hourIndex += 1
      
      requests.append(request)
    }
    
      scheduleNotification()
    debugPrint(#line, "End", requests.count)
    return requests
  }
    
    func scheduleNotification() {
        
        
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.subtitle = "subtitle, subtitle, subtitle"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 09
        dateComponents.minute = 50
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: 60.0,
                    repeats: true)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
                    content: content,
                    trigger: trigger
                )
        
        center.add(request) { error in
            if let error = error {
              print(error)
            }
          }
    }
  
  mutating func buildNotifications(words: [Word]) -> Effect<[UNNotificationRequest], Never> {
    Effect(value: self.buildNotificationRequests(words: words))
  }
  
  mutating func addNotifications(
    words: [Word],
    environment: WordEnvironment
  ) -> Effect<Void, Error>  {
    
    return Effect.merge(
      self.buildNotificationRequests(words: words).map { request in
        environment.userNotificationClient.add(request)
          .mapError({ _ in  HTTPRequest.HRError.nonHTTPResponse })
          .fireAndForget()
      }
    )
  }
  
  mutating func addNotificationsActionEffectResult(
    words: [Word],
    environment: WordEnvironment) -> Effect<WordAction, Never> {
      debugPrint(#line, "concatenate 2st")
      return self.addNotifications(words: words, environment: environment)
        .fireAndForget()
    }
}
