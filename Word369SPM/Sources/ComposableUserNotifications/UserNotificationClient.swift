import Combine
import ComposableArchitecture
import UserNotifications

public struct UserNotificationClient {
  public var add: (UNNotificationRequest) -> Effect<Void, Error>
  public var delegate: Effect<DelegateEvent, Never>
  public var getNotificationSettings: Effect<Notification.Settings, Never>
  public var removeDeliveredNotificationsWithIdentifiers: ([String]) -> Effect<Never, Never>
  public var removePendingNotificationRequestsWithIdentifiers: ([String]) -> Effect<Never, Never>
  public var requestAuthorization: (UNAuthorizationOptions) -> Effect<Bool, Error>

  public enum DelegateEvent: Equatable {
    case didReceiveResponse(Notification.Response, completionHandler: () -> Void)
    case openSettingsForNotification(Notification?)
    case willPresentNotification(
      Notification, completionHandler: (UNNotificationPresentationOptions) -> Void)

    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case let (.didReceiveResponse(lhs, _), .didReceiveResponse(rhs, _)):
        return lhs == rhs
      case let (.openSettingsForNotification(lhs), .openSettingsForNotification(rhs)):
        return lhs == rhs
      case let (.willPresentNotification(lhs, _), .willPresentNotification(rhs, _)):
        return lhs == rhs
      default:
        return false
      }
    }
  }

  public struct Error: Swift.Error, Equatable {
    public let error: NSError

    public init(_ error: Swift.Error) {
      self.error = error as NSError
    }
  }

  public struct Notification: Equatable {
    public var date: Date
    public var request: UNNotificationRequest

    public init(
      date: Date,
      request: UNNotificationRequest
    ) {
      self.date = date
      self.request = request
    }

    public struct Response: Equatable {
      public var notification: Notification

      public init(notification: Notification) {
        self.notification = notification
      }
    }

    // TODO: should this be nested in UserNotificationClient instead of Notification?
    public struct Settings: Equatable {
      public var authorizationStatus: UNAuthorizationStatus

      public init(authorizationStatus: UNAuthorizationStatus) {
        self.authorizationStatus = authorizationStatus
      }
    }
  }
}
