//
//  WordView.swift
//  
//
//  Created by Saroar Khandoker on 24.11.2021.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import ComposableUserNotifications
import SharedModels
import HTTPRequestKit
import WordClient
import Combine

public struct WordState: Equatable {

  public var words: IdentifiedArrayOf<Word> = []
  public var wordsFromUD: [Word] = []
  public var dayWords: [DayWords] = []
  public var currentHour = Calendar.current.component(.hour, from: Date())
  public var currentDay: Int = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
  public var startHour: Int = 9
  public var endHour: Int = 20
  public var currentDate = Date().get(.day, .month, .year)
  public var hourIndx = 0
  public var dateComponents = DateComponents()

  public init(
    words: IdentifiedArrayOf<Word> = [],
    wordsFromUD: [Word] = [],
    dayWords: [DayWords] = []
  ) {
    self.words = words
    self.wordsFromUD = wordsFromUD
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
      isReadFromView: false
    ),

      .init(
        englishWord: "Apple 2",
        englishDefinition: "Eat one apple a day keeps doctor away",

        russianWord: "Яблоко 2",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",

        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",

        isReadFromNotification: false,
        isReadFromView: false
      ),

      .init(
        englishWord: "Apple 3",
        englishDefinition: "Eat one apple a day keeps doctor away",

        russianWord: "Яблоко 3",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",

        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",

        isReadFromNotification: false,
        isReadFromView: false
      ),

      .init(
        englishWord: "Apple 4",
        englishDefinition: "Eat one apple a day keeps doctor away",

        russianWord: "Яблоко 4",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",

        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",

        isReadFromNotification: false,
        isReadFromView: false
      ),

      .init(
        englishWord: "Apple 5",
        englishDefinition: "Eat one apple a day keeps doctor away",

        russianWord: "Яблоко 5",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",

        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",

        isReadFromNotification: false,
        isReadFromView: false
      ),

      .init(
        englishWord: "Apple 6",
        englishDefinition: "Eat one apple a day keeps doctor away",

        russianWord: "Яблоко 6",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",

        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",

        isReadFromNotification: false,
        isReadFromView: false
      ),

      .init(
        englishWord: "Apple 7",
        englishDefinition: "Eat one apple a day keeps doctor away",

        russianWord: "Яблоко 7",
        russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",

        banglaWord: "苹果",
        banglaDefinition: "每天吃一个苹果让医生远离",

        isReadFromNotification: false,
        isReadFromView: false
      )
  ]

  static public var dayWordsMock: DayWords = .init(id: 2, words: [
    .init(
      englishWord: "Apple 7",
      englishDefinition: "Eat one apple a day keeps doctor away",

      russianWord: "Яблоко 7",
      russianDefinition: "Съедайте по одному яблоку в день, чтобы доктор не приходил",

      banglaWord: "苹果",
      banglaDefinition: "每天吃一个苹果让医生远离",

      isReadFromNotification: false,
      isReadFromView: false
    )
  ]
  )
  static public var mock: WordState = .init(words: wordsMock, dayWords: [dayWordsMock])
}

public enum WordAction: Equatable {
  case onApper

  case wordResponse(Result<[Word], HTTPRequest.HRError>)

  case receiveUserDefaultsWords(Result<[Word], Never>)

  case requestDayWords([Word])
  case receiveDayWords(Result<[DayWords], NSError>)

  case userNotifications(UserNotificationClient.DelegateEvent)
}

public struct WordEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var userNotificationClient: UserNotificationClient
  public var userDefaultsClient: UserDefaultsClient
  public var wordClient: WordClient

  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    userNotificationClient: UserNotificationClient,
    userDefaultsClient: UserDefaultsClient,
    wordClient: WordClient
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.userNotificationClient = userNotificationClient
    self.userDefaultsClient = userDefaultsClient
    self.wordClient = wordClient
  }
}

extension WordEnvironment {
  static public var live: WordEnvironment = .init(
    mainQueue: .main, backgroundQueue: .main,
    userNotificationClient: .live,
    userDefaultsClient: .live(),
    wordClient: .live

  )

  static public var mock: WordEnvironment = .init(
    mainQueue: .immediate, backgroundQueue: .immediate,
    userNotificationClient: .noop,
    userDefaultsClient: .noop,
    wordClient: .live
  )
}

public let wordReducer = Reducer<
  WordState, WordAction, WordEnvironment
> { state, action, environment in

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
        if let row = dayWords.firstIndex(where: { $0.id == state.currentDay }) {
          state.wordsFromUD = dayWords[row].words
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
  }
}

public struct WordView: View {

  let store: Store<WordState, WordAction>

  public init(store: Store<WordState, WordAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store) { viewStore in
      List {
        ForEach(viewStore.state.wordsFromUD) { word in
          VStack {
            Spacer()
            HStack {
              Text(word.englishWord)
              if word.russianWord != nil {
                Text("-> " + word.russianWord!)
              }
            }
            .font(.title)
            .padding()


            Image(systemName: "person")
              .resizable()
              .scaledToFit()
              .padding()


            VStack {
              Text(word.englishDefinition)
              Text(word.russianDefinition ?? "")
            }
            .font(.title3)
            .padding()

            Spacer()
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
      }
      .listStyle(PlainListStyle())
      .onAppear { viewStore.send(.onApper) }
    }
    .navigationTitle("Your words")
  }
}

struct WordView_Previews: PreviewProvider {

  static var store = Store(
    initialState: WordState.mock,
    reducer: wordReducer,
    environment: WordEnvironment.mock)

  static var previews: some View {
    WordView(store: store)
  }
}


extension UserDefaults {
  // MARK: - Words
  @UserDefaultPublished(UserDefaultKeys.wordBeginner.rawValue, defaultValue: [])
  public static var words: [Word]

  @UserDefaultPublished(UserDefaultKeys.dayWordsBeginner.rawValue, defaultValue: [])
  public static var dayWords: [DayWords]

}

import Foundation
import ComposableArchitecture

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

extension WordState {
  mutating func buildDayWords(words: [Word]) -> [DayWords] {

    dayWords.append(DayWords(id: self.currentDay))

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
      print(fromDayStartHourToEndHours.map { $0} )
      if hourIndex == fromDayStartHourToEndHours.count {
        hourIndex = 0
        // when 1st day is finished
        // start 2nd dayHours from 0 -> how i can start 2nd day here
        startNextHourFromCurrent = startHour - 1 // set start hour from currentNextHour

        currentDay += 1
      }

      if let row = dayWords.firstIndex(where: { $0.id == currentDay }) {
        dayWords[row].words.append(Word(word))
      } else {
        dayWords.append(DayWords(id: currentDay, words: [Word(word)]))
      }

      hourIndex += 1

    }
    
    if let row = dayWords.firstIndex(where: { $0.id == self.currentDay }) {
      self.wordsFromUD = dayWords[row].words
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

    print(#line, "Start", requests.count)

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
      content.title = word.englishWord
      content.body = word.englishDefinition
      content.categoryIdentifier = "com.addame.words300"
      content.sound = UNNotificationSound.default

      let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      let request = UNNotificationRequest(identifier: word.id, content: content, trigger: trigger)

      hourIndex += 1

      requests.append(request)

    }

    print(#line, "End", requests.count)
    return requests
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

     return self.addNotifications(words: words, environment: environment)
      .fireAndForget()

  }
}
