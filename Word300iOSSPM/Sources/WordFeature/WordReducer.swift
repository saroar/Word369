//
//  WordReducer.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import ComposableUserNotifications
import SharedModels
import HTTPRequestKit
import WordClient
import DayWordCardsFeature
import DayWordCardFeature
import SettingsFeature

extension UserDefaults {
    // MARK: - Words
    @UserDefaultPublished(UserDefaultKeys.wordBeginner.rawValue, defaultValue: [])
    public static var words: [Word]

    @UserDefaultPublished(UserDefaultKeys.dayWordsBeginner.rawValue, defaultValue: [])
    public static var dayWords: [DayWords]

    // MARK: - Words
    @UserDefaultPublished(UserDefaultKeys.currentLanguage.rawValue, defaultValue: LanguageCode.empty)
    public static var currentLanguage: LanguageCode

    @UserDefaultPublished(UserDefaultKeys.learnLanguage.rawValue, defaultValue: LanguageCode.empty)
    public static var learnLanguage: LanguageCode
}

public class UserDefaultsDataProvider {
  public static var wordsPublisher: Effect<[Word], Never> {
    UserDefaults.$words.eraseToEffect()
  }
  
  public static  func updateWordDictionary<Value>(newValue: Value) {
    let newWords = UserDefaults.words
    //        newWords == newValue
    if UserDefaults.words == newWords { return }
    UserDefaults.words = newWords
  }
}


public let wordReducer = Reducer<
  WordState, WordAction, WordEnvironment
>.combine(
    settingsReducer
    .optional()
    .pullback(
        state: \.settingsState,
        action: /WordAction.settings,
        environment: { _ in
            SettingsEnvironment.live
        }
    ),
  dayWordCardsReducer
    .pullback(
      state: \.dayWordCardState,
      action: /WordAction.dayWords,
      environment: { _ in DayWordCardsEnvironment(mainQueue: .main) }
    ),
  Reducer { state, action, environment in
    
    switch action {
    case .onApper:
        
      state.isLoading = true      
      state.startHour = environment.userDefaultsClient.integerForKey(UserDefaultKeys.startHour.rawValue)
      state.endHour = environment.userDefaultsClient.integerForKey(UserDefaultKeys.endHour.rawValue)
      
      state.dateComponents.calendar = Calendar.current
      state.dateComponents.calendar?.timeZone = .current
      state.dateComponents.day = state.currentDay
      
      UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
        for notification in notifications {
          debugPrint(#line, "DeliveredNotification", notification.request.content.userInfo)
        }
      }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
          for notification in notifications {
              debugPrint(#line, "PendingNotification", notification.content.userInfo)
          }
        }
   
        if state.from == "" || state.to == "" {
            //send logs
            return .none
        }
        
        if state.isSettingsNavigationActive {
            state.isLoading = false
          return .none // for now
        }
        
        return environment.wordClient.words(state.from, state.to)
            .subscribe(on: environment.backgroundQueue)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(WordAction.wordResponse)
      
    case let .wordResponse(.success(responseWords)):
 
      let dayWords = UserDefaults.dayWords
      let nestedWords = dayWords
        .map { $0.words }
        .flatMap { $0 }
      
      if state.isSettingsNavigationActive {
        return .none // for now
      }
      
      if UserDefaults.words == responseWords {
        if nestedWords == responseWords {
            state.buildTodayWordCardStates(dayWords)
          return .concatenate(
            environment.userNotificationClient
              .removePendingNotificationRequestsWithIdentifiers(["com.addame.words300"])
              .fireAndForget(),
            Effect(value: WordAction.requestDayWords(responseWords))
                  .receive(on: environment.mainQueue)
                  .eraseToEffect()
          )
          
        }
        
        return  Effect(value: WordAction.requestDayWords(responseWords))
                  .receive(on: environment.mainQueue)
                  .eraseToEffect()
        
      }
      
      var wordBeginner = responseWords.filter { $0.level == .beginner }
      UserDefaults.words = wordBeginner
      
      return .concatenate(
        environment.userNotificationClient
          .removePendingNotificationRequestsWithIdentifiers(["com.addame.words300"])
          .fireAndForget(),
      
        UserDefaultsDataProvider.wordsPublisher
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(WordAction.receiveUserDefaultsWords)
        )
    
    case let .wordResponse(.failure(error)):
      // handle error
        state.isLoading = false
      return .none
      
    case let .receiveDayWords(.success(responseDayWords)):
      state.isLoading = false
      debugPrint(#line, responseDayWords)
      
      return  .none
      
    case let .receiveDayWords(.failure(error)):
      state.isLoading = false
        assertionFailure("api request fail \(error.localizedDescription)")
      // handle error
      return .none
      
    case let .receiveUserDefaultsWords(.success(udwords)):
        return state.buildDayWordsAndAddNotification(words: udwords, environment: environment)
      
    case let .receiveUserDefaultsWords(.failure(error)):
        state.isLoading = false
      return .none
      
    case let .requestDayWords(words):
        return state.buildDayWordsAndAddNotification(words: words, environment: environment)
      
    case .userNotifications: return .none

    case .dayWords: return .none
      
    case let .settingsView(boolValue):
        state.settingsState = boolValue ? SettingsState() : nil
        
        state.isLoading = false
        return .none
    
    case .settings(_): return .none
      
    }
  }
)
