import ComposableArchitecture
import SharedModels
import Combine
import ComposableUserNotifications
import XCTest

@testable import WordFeature

final class WordFeatureTests: XCTestCase {
    
    let scheduler = DispatchQueue.test
    var environment = WordEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
//        userNotificationClient: .mock(),
        userNotificationClient: .mock(
              requestAuthorization: { _ in Effect(value: true) }
            ),
        userDefaultsClient: .noop,
        wordClient: .empty
    )
    
    
    func testWordsFetchRequest() throws {
        let delegateActionSubject = PassthroughSubject<UserNotificationClient.Action, Never>()
        var didSubscribeNotifications = false
        var didRequestAuthrizationOptions: UNAuthorizationOptions?
        environment.userNotificationClient.requestAuthorization = { options in
          didRequestAuthrizationOptions = options
          return Effect(value: true)
        }

        environment.userNotificationClient.delegate = {
          didSubscribeNotifications = true
          return delegateActionSubject.eraseToEffect()
        }
        
        environment.userDefaultsClient.integerForKey = { _ in 20 }
        
        let content = UNMutableNotificationContent()
        content.userInfo = ["count": 5]
        let notification = Notification(
          date: Date(timeIntervalSince1970: 0),
          request: Notification.Request(
            identifier: "fixture",
            content: Notification.Content(rawValue: content),
            trigger: nil
          )
        )
        
//        let notification = Notification(rawValue: notification)
        environment.userNotificationClient.getDeliveredNotifications = { return Effect(value: [notification]) }
        
        var removedPendingIdentifiers: [String]?
        environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers = { identifiers in
          removedPendingIdentifiers = identifiers
          return .fireAndForget {}
        }
        
        
        environment.userNotificationClient.getPendingNotificationRequests = {
            return Effect(value: [notification.request])
        }
        
        var notificationRequest: UNNotificationRequest?
        environment.userNotificationClient.add = { request in
          notificationRequest = request
          return Effect(value: ())
        }
        
        var state = WordState(
            dayWordCardState: .mockCardsState,
            isLoading: true,
            from: "english",
            to: "russian"
        )
        
        
        let store = TestStore(
            initialState: state,
            reducer: wordReducer,
            environment: environment
        )
        

        store.send(.onApper)
        self.scheduler.advance(by: 1)
//        state.startHour = 8
//        state.endHour = 20
        store.receive(.wordResponse(.success(Word.mockDatas))) {
//            $0.startHour = 8
//            $0.endHour = 20
            $0.isLoading = false
            $0.words = WordState.wordsMock
        }
        
    }
}
