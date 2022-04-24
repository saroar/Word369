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
import SwiftUI

extension WordState {
    
  mutating func buildTodayWordCardStates(_ dayWords: [DayWords]) {
        if let row = dayWords.firstIndex(where: { $0.dayNumber == self.currentDayInt }) {
            todayWords = .init(uniqueElements: dayWords[row].words.filter { $0.isReadFromView == false })

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
    
  private mutating func buildDayWords(words: [Word]) -> [DayWords] {
    
        dayWords.append(DayWords(dayNumber: self.currentDayInt))
        
        var hourIndex = self.hourIndx
        var currentHour = self.currentHour
        let startHour = self.startHour
        let endHour = self.endHour
        var currentDay = self.currentDayInt
        
        var startNextHourFromCurrent = currentHour + 1
        
        /// if current hour bigther or eqal
        if currentHour >= endHour {
          currentDay += 1
          currentHour = startHour
        }
      
        print(#line, UserDefaults.dayWords.count)
        if UserDefaults.words == words && !UserDefaults.dayWords.isEmpty {
          dayWords = UserDefaults.dayWords
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
      }
    
    return dayWords
  }
  
  mutating func buildDayWordsEffect(words: [Word]) -> Effect<[DayWords], Never> {
    Effect(value: self.buildDayWords(words: words))
  }
    
    private func add(word: Word, trigger: UNCalendarNotificationTrigger) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = word.buildNotificationTitle(from: from, to: to)
        content.body = word.buildNotificationDefinition(from: from, to: to)
        content.categoryIdentifier = "com.addame.words300"
        content.sound = UNNotificationSound.default
        
        return UNNotificationRequest(identifier: word.id, content: content, trigger: trigger)
    }
    
    private mutating func buildNotificationRequests(words: [Word]) -> [UNNotificationRequest] {
        
        var hourIndex = hourIndx
        var currentHour = currentHour
        let startHour = startHour
        let endHour = endHour
        var currentDayInt = currentDayInt
        
        /// if current hour bigther or eqal
        if currentHour >= endHour {
            dateComponents.day! += 1
            currentHour = startHour
        }
        
        var currentHourNext = currentHour + 1
        
        var requests = [UNNotificationRequest]()
        
        for (idx, word) in words.enumerated() where idx < 63 {
            let center = UNUserNotificationCenter.current()
            let fromDayStartHourToEndHours = (currentHourNext...endHour).map { $0 }
            
            // 1st day start from 9 to 20
            if hourIndex == fromDayStartHourToEndHours.count {
                hourIndex = 0
                // when 1st day is finished
                // start 2nd dayHours from 0 -> how i can start 2nd day here
                currentHourNext = startHour - 1 // set start hour from currentNextHour
                currentDayInt += 1
            }
            
            let gregorian = Calendar(identifier: .gregorian)
            let now = Date()
            var dateComponents = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
            dateComponents.timeZone = .current
            
            dateComponents.day = currentDayInt
            dateComponents.hour = Date().hour// fromDayStartHourToEndHours[hourIndex]
            dateComponents.minute = Date().minute + 1
        
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = add(word: word, trigger: trigger)
            
            if currentDayInt >= 365 { currentDayInt = 1 }
            hourIndex += 1
        
            requests.append(request)
            
            center.add(request, withCompletionHandler: {(error) in
                if error != nil {
                    print("SOMETHING WENT WRONG")
                }
            })
        }
            
        return requests
        
    }
    
  mutating func buildNotificationRequestsEffect(words: [Word]) -> Effect<[UNNotificationRequest], Never> {
    Effect(value: self.buildNotificationRequests(words: words))
  }
    
    mutating func buildNotifications(words: IdentifiedArrayOf<Word>) -> Effect<WordAction, Never> {
        
        var now = Date().toLocalTime()
        var nextDay = 0
        
        var hourIndex = hourIndx
        var currentHour = currentHour
        let startHour = startHour
        let endHour = endHour
        var currentDayInt = currentDayInt
        
        /// if current hour bigther or eqal
        if currentHour >= endHour {
            dateComponents.day! += 1
            nextDay += 1
            now = now.adding(days: nextDay)!
            currentHour = startHour
        }
        
        var currentHourNext = currentHour + 1
        let maxNotifications = 64
        var countMaxNotifications = 0
        
        for word in words where countMaxNotifications <= maxNotifications {
            
            let fromDayStartHourToEndHours = (currentHourNext...endHour).map { $0 }

            // 1st day start from 9 to 20
            if hourIndex == fromDayStartHourToEndHours.count {
                hourIndex = 0
                // when 1st day is finished
                // start 2nd dayHours from 0 -> how i can start 2nd day here
                currentHourNext = startHour - 1 // set start hour from currentNextHour
                currentDayInt += 1
                nextDay += 1
                now = now.adding(days: nextDay)!
            }
            let hour = fromDayStartHourToEndHours[hourIndex]
           
            scheduleNotification(word: word, date: now, hour: hour)

            if currentDayInt >= daysInYear { currentDayInt = 1 }
            hourIndex += 1
            countMaxNotifications += 1
        }
        
        return .none
    }

 private mutating func addNotifications(
    words: [Word],
    environment: WordEnvironment
  ) -> Effect<WordAction, Never> {

    return .merge(
        self.buildNotificationRequests(words: words).map { request in
            environment.userNotificationClient.add(request)
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: environment.backgroundQueue)
                .mapError({ _ in  HTTPRequest.HRError.nonHTTPResponse })
                .fireAndForget()
        }
    )
  }
  
  mutating func addNotificationsActionEffectResult(
    words: [Word],
    environment: WordEnvironment) -> Effect<WordAction, Never> {
      debugPrint(#line, "concatenate 2st")
      return addNotifications(words: words, environment: environment)
  }

    func scheduleNotification(word: Word, date: Date, hour: Int) {

        let center = UNUserNotificationCenter.current()
        let title  = word.buildNotificationTitle(from: from, to: to)
        let body = word.buildNotificationDefinition(from: from, to: to)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "com.addame.words300"

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        components.hour = hour
        
        let component = DateComponents.triggerFor(day: 0, hour: hour)
        let trigger =  UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
                      
        let request = UNNotificationRequest(identifier: word.id, content: content, trigger: trigger)
        print("INSIDE NOTIFICATION \(content.title)")
                        
        center.add(request, withCompletionHandler: {(error) in
            if error != nil {
                print("SOMETHING WENT WRONG")
            }
        })
        
//        center.getDeliveredNotifications { notifications in
//          for notification in notifications {
//              debugPrint(#line, "DeliveredNotification", notification)
//          }
//        }
//
//        center.getPendingNotificationRequests { notifications in
//            print(#line, "count-- \(notifications.count)" )
//            for notification in notifications {
//                debugPrint(#line, "PendingNotification", notification, notification.content.title)
//            }
//          }

    }
    
    
            
    //        let currentYear = calendar.component(.year, from: Date())
    //        (currentYear...(currentYear+100)).forEach {
    //          print("\($0): \(daysIn(year: $0))")
    //        }
    //
    
    mutating func removeDeleveriedNotifications() -> Effect<WordAction, Never> {
        for id in deliveredNotificationIDS {
            guard let _ = words[id: id] else {
                return .none // build from 0
            }
            
            words.remove(id: id)
        }
        
        return .none
    }
    
    var daysInYear: Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let firstDayOfNextYear = calendar.date(from: DateComponents(year: currentYear + 1, month: 1, day: 1))!
        let firstDayOfThisYear = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
        guard let daysInYear = calendar.dateComponents([.day], from: firstDayOfThisYear, to: firstDayOfNextYear).day
        else {
            assertionFailure("\(#line) daysInYear error")
            return 0
        }
        return daysInYear
    }
    // https://sarunw.com/posts/getting-number-of-days-between-two-dates/

}

extension DateComponents {
    static func triggerFor(day: Int, hour: Int) -> DateComponents {
        var component = DateComponents()
//        component.day = day
        component.hour = hour
        return component
    }
}

extension Date {

    /// Returns a Date with the specified amount of components added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }

    /// Returns a Date with the specified amount of components subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }

}


extension Date {
    func toLocalTime() -> Date {
        let timezone    = TimeZone.current
        let seconds     = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
