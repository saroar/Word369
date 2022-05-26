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
import Combine

extension UserDefaults {
    // MARK: - Words
    @UserDefaultPublished(UserDefaultKeys.wordBeginner.rawValue, defaultValue: [])
    public static var words: [Word]
    
    @UserDefaultPublished(UserDefaultKeys.deliveredNotificationWords.rawValue, defaultValue: [])
    public static var deliveredNotificationWords: [Word]

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
    // newWords == newValue
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
      struct WordID: Equatable {}
      
    switch action {
    case .onApper:
        
      state.isLoading = true      
      state.startHour = environment.userDefaultsClient.integerForKey(UserDefaultKeys.startHour.rawValue)
      state.endHour = environment.userDefaultsClient.integerForKey(UserDefaultKeys.endHour.rawValue)
   
        if state.from == "" || state.to == "" {
            //send logs
            return .none
        }
        
        if state.isSettingsNavigationActive {
            state.isLoading = false
          return .none // for now
        }
        
        return  environment.userNotificationClient.requestAuthorization([.alert, .badge, .sound])
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(WordAction.requestAuthorizationResponse)

    case let .wordResponse(.success(responseWords)):
        state.isLoading = false
        if state.isSettingsNavigationActive {
            return .none // for now
        }
        
        var wordBeginner = responseWords.filter { $0.level == .beginner }
        UserDefaults.words = wordBeginner
        state.words = .init(uniqueElements: wordBeginner)
        
      let dayWords = UserDefaults.dayWords
      let nestedWords = dayWords
        .map { $0.words }
        .flatMap { $0 }
      
        if UserDefaults.words == responseWords && nestedWords.count == responseWords.count {
              return Effect(value: dayWords)
                .receive(on: environment.mainQueue)
                .catchToEffect(WordAction.receiveDayWords)
        }
       
        return Effect(value: WordAction.receiveUserDefaultsWords(UserDefaults.words))
            .receive(on: environment.mainQueue)
            .eraseToEffect()
        
    case let .wordResponse(.failure(error)):
      // handle error
        state.isLoading = false
      return .none
      
    case let .receiveDayWords(.success(dayWords)):
        state.buildTodayWordCardStates(dayWords)
                
        return environment.userNotificationClient.getDeliveredNotifications()
            .receive(on: environment.mainQueue)
            .catchToEffect(WordAction.receiveDeliveredNotifications)
      
    case let .receiveUserDefaultsWords(words):

        for word in words where state.deliveredNotificationIDS.contains(word.id) {
            state.deliveredNotificationWords.append(word)
        }
        
        return state.buildDayWordsEffect(words: words)
            .receive(on: environment.mainQueue)
            .catchToEffect(WordAction.receiveDayWords)
      
    case let .requestDayWords(words):
        state.isLoading = false
        return .none
    
        
    case let .userNotifications(.openSettingsForNotification(notification)):
        debugPrint(#line, notification)
        return .none

    case let .userNotifications(.didReceiveResponse(response, completionHandler)):
        print(#line, response, completionHandler)
        return .none
        
    case let .userNotifications(.willPresentNotification(_, completionHandler)):
        return .fireAndForget {
            completionHandler([.list, .badge, .banner, .sound])
        }
        
    case .userNotifications: return .none

    case .dayWords: return .none
      
    case let .settingsView(boolValue):
        state.settingsState = boolValue ? SettingsState() : nil
        
        state.isLoading = false
        return .none
    
    case .settings(_): return .none
      
    case let .receiveDeliveredNotifications(.success(notifications)):
        state.deliveredNotificationIDS = notifications.map { $0.request.identifier }
        
        return .concatenate(

            environment.userNotificationClient
              .removePendingNotificationRequestsWithIdentifiers(["com.addame.words300"])
              .fireAndForget(),

            state.removeWordFromDeleveriedNotificationsList()
                .receive(on: environment.mainQueue)
                .fireAndForget(),

            state.addNotifications(words: state.words, environment: environment)
                .receive(on: environment.mainQueue)
                .fireAndForget(),

            environment.userNotificationClient.getPendingNotificationRequests()
                .receive(on: environment.mainQueue)
                .catchToEffect(WordAction.getPendingNotificationRequests)
        )

    case let .getPendingNotificationRequests(.success(notifications)):
        print("getPendingNotificationRequests", notifications.map { $0 } )
        return .none

    case .requestAuthorizationResponse(.success(let value)):
        if value {
            return environment.wordClient.words(state.from, state.to)
                .receive(on: environment.mainQueue)
                .catchToEffect(WordAction.wordResponse)
        } else {
            state.isLoading = false
            return Effect(value: .alertButtonTapped)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
        }

    case .requestAuthorizationResponse(.failure):
        return .none
        
    case .alertButtonTapped:
        state.alert = .init(
          title: .init("Go to Settings?"),
          message: .init("Without allow notification this app will not work."),
          primaryButton: .default(TextState("Go To settings"), action: .send(.openSettingsURLString)),
          secondaryButton: .default(TextState("Cancel"), action: .send(.alertDismissed))
        )
        
        return .none
        
    case .alertDismissed:
        state.alert = nil
        return .none

    case .openSettingsURLString:
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        return .none
    }
  }
)
