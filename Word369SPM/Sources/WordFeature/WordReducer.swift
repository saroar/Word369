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

extension UserDefaults {
  // MARK: - Words
  @UserDefaultPublished(UserDefaultKeys.wordBeginner.rawValue, defaultValue: [])
  public static var words: [Word]
  
  @UserDefaultPublished(UserDefaultKeys.dayWordsBeginner.rawValue, defaultValue: [])
  public static var dayWords: [DayWords]
  
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
  dayWordCardsReducer
    .pullback(
      state: \.dayWordCardState,
      action: /WordAction.dayWords,
      environment: { _ in DayWordCardsEnvironment() }
    ),
  Reducer { state, action, environment in
    
    switch action {
    case .onApper:
      
      //    let defaults = UserDefaults.standard
      //    if let savedPerson = defaults.object(forKey: "wordBeginner") as? Data {
      //        let decoder = JSONDecoder()
      //        if let loadedPerson = try? decoder.decode([Word].self, from: savedPerson) {
      //          print(loadedPerson.count, loadedPerson[2].englishWord)
      //        }
      //    }
      
      state.startHour = environment.userDefaultsClient.integerForKey(UserDefaultKeys.startHour.rawValue)
      state.endHour = environment.userDefaultsClient.integerForKey(UserDefaultKeys.endHour.rawValue)
      
      state.dateComponents.calendar = Calendar.current
      state.dateComponents.calendar?.timeZone = .current
      state.dateComponents.day = state.currentDay
      
      //    UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
      //      for notification in notifications {
      //        print(#line, notification.request.content.userInfo)
      //      }
      //    }
      
      return environment.wordClient.words()
        .subscribe(on: environment.backgroundQueue)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(WordAction.wordResponse)
      
      
    case let .wordResponse(.success(responseWords)):
      
      var wordBeginner = responseWords.filter { $0.level == .beginner }
      UserDefaults.words = wordBeginner
      
      let dayWords = UserDefaults.dayWords
      let nestedWords = dayWords
        .map { $0.words }
        .flatMap { $0 }
      
      if UserDefaults.words == responseWords {
        if nestedWords == responseWords {
          if let row = dayWords.firstIndex(where: { $0.dayNumber == state.currentDay }) {
            state.todayWords = .init(uniqueElements: dayWords[row].words)
            
            let cardState: IdentifiedArrayOf<DayWordCardState> = .init(uniqueElements: dayWords[row].words.map { DayWordCardState.init(word: $0) })
            state.dayWordCardState = .init(dayWordCardStates: cardState )
          }
          
          return .none
        }
        
        return Effect(value: WordAction.requestDayWords(responseWords))
          .receive(on: environment.mainQueue)
          .eraseToEffect()
      }
      
      //    return .concatenate(
      //      environment.userNotificationClient
      //        .removePendingNotificationRequestsWithIdentifiers(["com.addame.words300"])
      //        .fireAndForget()
      //    )
      
      return UserDefaultsDataProvider.wordsPublisher
      //        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(WordAction.receiveUserDefaultsWords)
      
      
      //environment.userDefaultsClient.setData(encoded, UserDefaultKeys.wordBeginner.rawValue)
      //.fireAndForget()
      
      //    environment.wordDataProvider.insertWords(words: responseWords)
      //      .subscribe(on: DispatchQueue.global(qos: .userInitiated))
      //      .receive(on: environment.mainQueue)
      //      .mapError({ _ in  HTTPRequest.HRError.nonHTTPResponse })
      //      .catchToEffect()
      //      .map(WordAction.wordEntityResponse)
      
      
      //          return .concatenate(
      //            environment.userNotificationClient
      //              .removePendingNotificationRequestsWithIdentifiers(["example_notification"])
      //              .fireAndForget()
      //          )
      
      //      return .concatenate(
      //        buildNotifications(words: response)
      //      )
      
      //    return .none
      
    case let .wordResponse(.failure(error)):
      // handle error
      return .none
      
    case let .receiveDayWords(.success(responseDayWords)):
      
      print(#line, responseDayWords)
      
      return  .none
      
    case let .receiveDayWords(.failure(error)):
      
      // handle error
      return .none
      
    case let .receiveUserDefaultsWords(.success(udwords)):
      
      // create some business logic for avoid create every time notification
      return state.addNotificationsActionEffectResult(words: udwords, environment: environment)
        .receive(on: environment.mainQueue)
        .eraseToEffect()
      
    case let .receiveUserDefaultsWords(.failure(error)):
      return .none
      
    case let .requestDayWords(words):
      return state.buildDayWordsEffectResult(words: words)
        .receive(on: environment.mainQueue)
        .eraseToEffect()
      
    case .userNotifications:
      return .none
      
    case .dayWords: return .none
      
    }
  }
)
