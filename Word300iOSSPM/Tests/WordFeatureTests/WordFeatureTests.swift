import ComposableArchitecture
import SharedModels
import Combine
import ComposableUserNotifications
import UserDefaultsClient
import UserNotifications
import XCTest

@testable import WordFeature

final class WordFeatureTests: XCTestCase {
    
    let scheduler = DispatchQueue.test
    
    func testWordsFetchRequest() throws {
        
        var state = WordState(
            from: "english",
            to: "russian"
        )
        
        let store = TestStore(
            initialState: state,
            reducer: wordReducer,
            environment: .happyPath
        )
        
        store.environment.mainQueue = scheduler.eraseToAnyScheduler()
        store.environment.backgroundQueue = scheduler.eraseToAnyScheduler()
        
        let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
        var didSubscribeNotifications = false
        var didRequestAuthrizationOptions: UNAuthorizationOptions?
        store.environment.userNotificationClient.requestAuthorization = { options in
          didRequestAuthrizationOptions = options
          return Effect(value: true)
        }

        store.environment.userNotificationClient.delegate = {
          didSubscribeNotifications = true
          return delegateActionSubject.eraseToEffect()
        }

        store.environment.userDefaultsClient.override(integer: 9, forKey: UserDefaultKeys.endHour.rawValue)
        
        let word = state.words[0]
        let content = UNMutableNotificationContent()
        content.title = word.englishTitle
        content.body = word.englishDefinition
        
        
        state.dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: state.today)
        state.dateComponents.calendar?.timeZone = .current
        state.dateComponents.hour = state.today.hour
        state.dateComponents.month = 03
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: state.dateComponents, repeats: false)
        let notification = Notification(
            date: Date().toLocalTime(),
          request: Notification.Request(
            identifier: word.id,
            content: Notification.Content(rawValue: content),
            trigger: nil
          )
        )
        
        store.environment.userNotificationClient.getDeliveredNotifications = { return Effect(value: [notification]) }
        
        var removedPendingIdentifiers: [String]?
        store.environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers = { identifiers in
          removedPendingIdentifiers = identifiers
          return .fireAndForget {}
        }
        
        
        store.environment.userNotificationClient.getPendingNotificationRequests = {
            return Effect(value: [notification.request])
        }
        
        var notificationRequest: UNNotificationRequest?
        store.environment.userNotificationClient.add = { request in
          notificationRequest = request
          return Effect(value: ())
        }
        

        store.environment.userDefaultsClient.override(integer: 20, forKey: UserDefaultKeys.endHour.rawValue)
        
        store.send(.onApper) {
            $0.isLoading = true
        }
        self.scheduler.advance(by: 0.3)
        store.receive(.wordResponse(.success(Word.mockDatas))) {
            $0.isLoading = false
            $0.words = .init(uniqueElements: Word.mockDatas)
        }
        
        self.scheduler.advance(by: 0.3)
        store.receive(.receiveUserDefaultsWords(Word.mockDatas))
        {
            $0.dayWords = [DayWords.happyPath]
            $0.dayWordCardState = .mockCardsState
            $0.todayWords = .init(uniqueElements: Word.mockDatas)
        }
        
        self.scheduler.advance(by: 0.3)
        store.receive(.receiveDayWords(.success([DayWords.happyPath]))) { _ in
//            $0.dayWords = [DayWords(dayNumber: 115, words: [])]
//            $0.dateComponents = DateComponents()
        }
//        
//        self.scheduler.advance(by: 0.3)
        store.receive(.receiveDeliveredNotifications(.success([notification]))) {
            $0.dateComponents = DateComponents(year: 2022, month: 1, day: 28, hour: 8, minute: Date().minute)
            $0.deliveredNotificationIDS = ["fixture"]
        }
        
//        self.scheduler.advance(by: 0.3)
        store.receive(.getPendingNotificationRequests(.success([notification.request])))
        {
            $0.dateComponents = DateComponents(year: 2022, month: 5, day: 27, hour: Date().hour, minute: Date().minute)

        }
        
    }
}
























































































































































































































































































































































