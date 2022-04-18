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
import UserNotifications

extension WordState {
    
    mutating func buildTodayWordCardStates(_ dayWords: [DayWords]) {
        if let row = dayWords.firstIndex(where: { $0.dayNumber == self.currentDay }) {
            todayWords = .init(uniqueElements: dayWords[row].words)
            let cardState: IdentifiedArrayOf<DayWordCardState> = .init(
                uniqueElements: todayWords
                    .enumerated()
                    .map { idx, word in
                        DayWordCardState.init(id: idx, word: word)
                    }
            )
            self.dayWordCardState = .init(dayWordCardStates: cardState )
        }
    }
    
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
      
        print(#line, UserDefaults.dayWords.count)
        if UserDefaults.words == words && !UserDefaults.dayWords.isEmpty {
          dayWords = UserDefaults.dayWords
            buildTodayWordCardStates(dayWords)
      } else {
          for word in words {
  
            let fromDayStartHourToEndHours = (startNextHourFromCurrent...endHour)
  
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
            
            if currentDay >= 365 {
               currentDay = 1
            }
            hourIndex += 1
            
          }
          
          UserDefaults.dayWords = dayWords
          buildTodayWordCardStates(dayWords)
      }
    
    return dayWords
  }
  
  mutating func buildDayWordsEffect(words: [Word]) -> Effect<[DayWords], Never> {
    Effect(value: self.buildDayWords(words: words))
  }
  
  mutating func buildDayWordsAndAddNotification(
    words: [Word],
    environment: WordEnvironment
  ) -> Effect<WordAction, Never> {
      return .concatenate(
        buildDayWordsEffectResult(words: words)
          .receive(on: environment.mainQueue)
          .eraseToEffect(),
        
        addNotificationsActionEffectResult(words: words, environment: environment)
          .receive(on: environment.mainQueue)
          .eraseToEffect()
      )
    }
    
  mutating func buildDayWordsEffectResult(words: [Word]) -> Effect<WordAction, Never> {
    Effect(value: .receiveDayWords(.success(self.buildDayWords(words: words))))
  }

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
      
        if currentDay >= 365 {
           currentDay = 1
        }
      hourIndex += 1
      
      requests.append(request)
    }
    
      scheduleNotification()
    debugPrint(#line, "End", requests.count)
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
      debugPrint(#line, "concatenate 2st")
      return self.addNotifications(words: words, environment: environment)
        .fireAndForget()
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
}
