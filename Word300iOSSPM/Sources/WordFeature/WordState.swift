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
import Helpers

public struct WordState: Equatable {
    
  public var words: IdentifiedArrayOf<Word> = []
  public var todayWords: IdentifiedArrayOf<Word> = []
  public var dayWords: [DayWords] = []
  public var deliveredNotificationWords: [Word] = []
    
  public var dayWordCardState: DayWordCardsState
  public var settingsState: SettingsState?

  public var isLoading = false
  public var isSettingsNavigationActive: Bool { self.settingsState != nil }

  public var today = Date()
  public var currentHour = Calendar.current.component(.hour, from: Date())
  public var currentDayInt: Int = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
  public var startHour: Int = 9
  public var endHour: Int = 20
  public var hourIndx = 0
  public var dateComponents = DateComponents()
    public var deliveredNotificationIDS: [String] = []
    
  public var from = UserDefaults.currentLanguage.name.lowercased()
  public var to = UserDefaults.learnLanguage.name.lowercased()
  
    public init(
        words: IdentifiedArrayOf<Word> = [],
        todayWords: IdentifiedArrayOf<Word> = [],
        dayWords: [DayWords] = [],
        deliveredNotificationWords: [Word] = [],
        dayWordCardState: DayWordCardsState,
        settingsState: SettingsState? = nil,
        isLoading: Bool = false,
        today: Date = Date(),
        currentHour: Int = Calendar.current.component(.hour, from: Date()),
        currentDayInt: Int = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0,
        startHour: Int = 9, endHour: Int = 20, hourIndx: Int = 0,
        dateComponents: DateComponents = DateComponents(),
        deliveredNotificationIDS: [String] = [],
        from: String = UserDefaults.currentLanguage.name.lowercased(),
        to: String = UserDefaults.learnLanguage.name.lowercased()
    ) {
        self.words = words
        self.todayWords = todayWords
        self.dayWords = dayWords
        self.deliveredNotificationWords = deliveredNotificationWords
        self.dayWordCardState = dayWordCardState
        self.settingsState = settingsState
        self.isLoading = isLoading
        self.today = today
        self.currentHour = currentHour
        self.currentDayInt = currentDayInt
        self.startHour = startHour
        self.endHour = endHour
        self.hourIndx = hourIndx
        self.dateComponents = dateComponents
        self.deliveredNotificationIDS = deliveredNotificationIDS
        self.from = from
        self.to = to
    }
}
