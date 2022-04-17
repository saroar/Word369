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
  public var dayWords: [DayWords] = []
    
  public var dayWordCardState: DayWordCardsState
  public var settingsState: SettingsState?

  public var isLoading = false
  public var isSettingsNavigationActive: Bool { self.settingsState != nil }

  public var currentHour = Calendar.current.component(.hour, from: Date())
  public var currentDay: Int = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
  public var startHour: Int = 9
  public var endHour: Int = 20
  public var currentDate = Date().get(.day, .month, .year)
  public var hourIndx = 0
  public var dateComponents = DateComponents()
    
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
