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
        let currentHourInt = self.currentHour
        let startHour = self.startHour
        let endHour = self.endHour
        var currentDay = self.currentDayInt
        var currentHourNext = currentHourInt + 1
       
        /// if current hour bigther or eqal
      if currentHourNext > endHour {
          currentHourNext = startHour
      }
      
        print(#line, UserDefaults.dayWords)
        
      for word in words {

        let fromDayStartHourToEndHours = (currentHourNext...endHour)

        if hourIndex == fromDayStartHourToEndHours.count {
          hourIndex = 0
          // when 1st day is finished
          // start 2nd dayHours from 0 -> how i can start 2nd day here
            currentHourNext = startHour - 1 // set start hour from currentNextHour
          
          currentDay += 1
    
        }
        
        if let row = dayWords.firstIndex(where: { $0.dayNumber == currentDay }) {
          dayWords[row].words.append(Word(word))
        } else {
          dayWords.append(DayWords(dayNumber: currentDay, words: [Word(word)]))
        }
        
        if currentDay >= daysInYear { currentDay = 1 }
        hourIndex += 1
        
      }

      UserDefaults.dayWords = dayWords
      
    
    return dayWords
  }
  
  mutating func buildDayWordsEffect(words: [Word]) -> Effect<[DayWords], Never> {
    Effect(value: self.buildDayWords(words: words))
  }
    
   private mutating func buildNotifications(words: IdentifiedArrayOf<Word>) -> [UNNotificationRequest] {
        
        var hourIndex = hourIndx
        let currentHour = currentHour
        let startHour = startHour
        let endHour = endHour
        var currentHourNext = currentHour + 1
        var requests: [UNNotificationRequest] = []
       
       if currentHourNext > endHour {
           currentHourNext = startHour
       }
       
       let totalNotifications = words.count >= 64 ? 64 : words.count
       
        for item in 0...totalNotifications - 1 {
            let word = words[item]
            
            var fromDayStartHourToEndHours = (currentHourNext...endHour).map { $0 }
            // 1st day start from 9 to 20
            if hourIndex > fromDayStartHourToEndHours.count - 1 {
                hourIndex = 0
                // when 1st day is finished
                // start 2nd dayHours from 0 -> how i can start 2nd day here
                currentHourNext = startHour - 1 // set start hour from currentNextHour
                today = today.adding(days: 1)!
                fromDayStartHourToEndHours = (currentHourNext...endHour).map { $0 }
            }
            
            let hour = fromDayStartHourToEndHours[hourIndex]
            let c = self.requiredComponents()
            print("hours--", hourIndex, hour, today)
            dateComponents = Calendar.autoupdatingCurrent.dateComponents(c, from: today)
            dateComponents.calendar?.timeZone = .current
            dateComponents.hour = hour
            dateComponents.minute = 01
            
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let title  = word.buildNotificationTitle(from: from, to: to)
            let body = word.buildNotificationDefinition(from: from, to: to)
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "com.addame.words300"

            let request = UNNotificationRequest(identifier: word.id, content: content, trigger: trigger)
            requests.append(request)

            hourIndex += 1
        }
        
        return requests
    }
    
    fileprivate func requiredComponents() -> Set<Calendar.Component> {

        return Set<Calendar.Component>.init(arrayLiteral: Calendar.Component.year, Calendar.Component.day, Calendar.Component.month, Calendar.Component.hour, Calendar.Component.minute)

    }
    
   mutating func addNotifications(
       words: IdentifiedArrayOf<Word>,
       environment: WordEnvironment
     ) -> Effect<Void, Error>  {
       
       return .merge(
                buildNotifications(words: words).map { request in
                   environment.userNotificationClient.add(request)
                       .mapError({ _ in  HTTPRequest.HRError.nonHTTPResponse })
                       .fireAndForget()
               }
         )
     }

    
    mutating func removeWordFromDeleveriedNotificationsList() -> Effect<WordAction, Never> {
        for id in deliveredNotificationIDS {
            guard let _ = words[id: id] else {
                return .none // build from 0
            }
            
            words.remove(id: id)
        }
        
        return .none
    }
    
    //        let currentYear = calendar.component(.year, from: Date())
    //        (currentYear...(currentYear+100)).forEach {
    //          print("\($0): \(daysIn(year: $0))")
    //        }
    //
    // https://sarunw.com/posts/getting-number-of-days-between-two-dates/
   private var daysInYear: Int {
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
    
}
