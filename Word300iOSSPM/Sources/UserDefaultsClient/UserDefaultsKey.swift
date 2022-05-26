//
//  UserDefaults.swift
//  
//
//  Created by Saroar Khandoker on 06.12.2021.
//

import Foundation

public enum UserDefaultKeys: String, CaseIterable {
  case userName, isFristTimeLunch, isWelcomeScreensFillUp, startHour, endHour,

  currentLanguage, learnLanguage, wordLevel,
  wordBeginner, wordIntermediate, wordAdvanced,
  dayWordsBeginner, dayWordsIntermediate, dayWordsAdvanced,
  deliveredNotificationWords, wordReminderCounters, totalWordReminders
}
