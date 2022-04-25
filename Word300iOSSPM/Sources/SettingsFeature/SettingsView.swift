//
//  SwiftUIView.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import SharedModels
import ComposableUserNotifications
import UserDefaultsClient

extension UserDefaults {
  // MARK: - Words
  @UserDefaultPublished(UserDefaultKeys.wordLevel.rawValue, defaultValue: "")
  public static var wordLevel: String
  
  @UserDefaultPublished(UserDefaultKeys.userName.rawValue, defaultValue: "")
  public static var username: String
}

public struct SettingsState: Equatable {
  
    public var name: String = UserDefaults.username
    public var wordLavel: String = WordLevel.beginner.rawValue
    public var notificationSettingsState: NotificationSettingsState?
    public var isSheetPresented: Bool { self.notificationSettingsState != nil }
    
    public init() {}
}

public enum SettingsAction: Equatable {
    case onAppear
    case setSheet(isPresented: Bool)
    case notificationSettings(NotificationSettingsAction)
}

public struct SettingsEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var userNotificationClient: UserNotificationClient
  public var userDefaultsClient: UserDefaultsClient
  
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    userNotificationClient: UserNotificationClient,
    userDefaultsClient: UserDefaultsClient
  ) {
    self.mainQueue = mainQueue
    self.userNotificationClient = userNotificationClient
    self.userDefaultsClient = userDefaultsClient
  }
}

extension SettingsEnvironment {
  
  public static let mock: SettingsEnvironment = .init(
      mainQueue: .immediate,
      userNotificationClient: UserNotificationClient.mock(),
      userDefaultsClient: UserDefaultsClient.noop
    )
  
  public static let live: SettingsEnvironment = .init(
      mainQueue: .main,
      userNotificationClient: UserNotificationClient.live,
      userDefaultsClient: UserDefaultsClient.live()
    )
  
}

public let settingsReducer = notificationSettingsReducer
    .optional()
    .pullback(
        state: \.notificationSettingsState,
        action: /SettingsAction.notificationSettings,
        environment: { _ in
            NotificationSettingsEnvironment(
                mainQueue: .main,
                userNotificationClient: .live
            )
        }
    )
    .combined(with: Reducer<SettingsState, SettingsAction, SettingsEnvironment> { state, action, environment in
      switch action {
      case .onAppear:
          state.name = environment.userDefaultsClient.stringForKey(UserDefaultKeys.userName.rawValue) ?? "missing name"
          return .none
      case let .setSheet(isPresented: boolValue):
          print(#line, "setSheet")
          state.notificationSettingsState = boolValue ? NotificationSettingsState() : nil
          return .none
          
      case .notificationSettings: return .none
      }
    }
)
  
public struct SettingsView: View {
  
  let store: Store<SettingsState, SettingsAction>
  
  public init(store: Store<SettingsState, SettingsAction>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading) {
        Text("Hello, \(viewStore.name)").font(.largeTitle)
        Text("Your Word Level: \(viewStore.wordLavel)")
          
      Button {
          viewStore.send(.setSheet(isPresented: true))
      } label: {
          Image(systemName: "bell")
              .font(.title)
              .foregroundColor(Color.red)
          
          Text("Notification Settings")
      }
      .padding()
        
        Spacer()
      }
      .onAppear { viewStore.send(.onAppear) }
      .sheet(isPresented: viewStore.binding(
        get: \.isSheetPresented,
        send: SettingsAction.setSheet(isPresented:))
      ) {
          IfLetStore(
            self.store.scope(
                state: \.notificationSettingsState,
                action: SettingsAction.notificationSettings
            ),
            then: NotificationSettingsView.init(store:),
            else: ProgressView.init
          )
      }
      .padding(.vertical)
      .frame(maxWidth: .infinity)
    }
  }
}


public struct NotificationSettingsState: Equatable {
  public var settings: UNNotificationSettings?
  
  public init() {}
}

public enum NotificationSettingsAction: Equatable {
    case onAppear
    case setting(Result<UNNotificationSettings, Never>)
}

public struct NotificationSettingsEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var userNotificationClient: UserNotificationClient
  
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    userNotificationClient: UserNotificationClient
  ) {
    self.mainQueue = mainQueue
    self.userNotificationClient = userNotificationClient
  }
}

extension NotificationSettingsEnvironment {
  
  public static let mock: NotificationSettingsEnvironment = .init(
      mainQueue: .immediate,
      userNotificationClient: UserNotificationClient.mock()
    )
  
  public static let live: NotificationSettingsEnvironment = .init(
      mainQueue: .main,
      userNotificationClient: UserNotificationClient.live
    )
  
}

let notificationSettingsReducer = Reducer<NotificationSettingsState, NotificationSettingsAction, NotificationSettingsEnvironment> { state, action, environment in
    
  switch action {
  case .onAppear:
      return .none
//      environment.userNotificationClient.getNotificationSettings
//          .receive(on: environment.mainQueue)
//          .catchToEffect()
//          .map(NotificationSettingsAction.setting)

  case let .setting(.success(settings)):
      state.settings = settings
      return .none

  case .setting(.failure):
      return .none
  }
}
public struct NotificationSettingsView: View {
    let store: Store<NotificationSettingsState, NotificationSettingsAction>
    public init(store: Store<NotificationSettingsState, NotificationSettingsAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
        VStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Text("Notification Settings").font(.title2)
                        Spacer()
                    }
                }
                
                Section {
                  SettingRowView(
                    setting: "Authorization Status",
                    enabled: viewStore.state.settings?.authorizationStatus == UNAuthorizationStatus.authorized)
                  SettingRowView(
                    setting: "Show in Notification Center",
                    enabled: viewStore.state.settings?.notificationCenterSetting == .enabled)
                  SettingRowView(
                    setting: "Sound Enabled?",
                    enabled: viewStore.state.settings?.soundSetting == .enabled)
                  SettingRowView(
                    setting: "Badges Enabled?",
                    enabled: viewStore.state.settings?.badgeSetting == .enabled)
                  SettingRowView(
                    setting: "Alerts Enabled?",
                    enabled: viewStore.state.settings?.alertSetting == .enabled)
                  SettingRowView(
                    setting: "Show on lock screen?",
                    enabled: viewStore.state.settings?.lockScreenSetting == .enabled)
                  SettingRowView(
                    setting: "Alert banners?",
                    enabled: viewStore.state.settings?.alertStyle == .banner)
                  SettingRowView(
                    setting: "Critical Alerts?",
                    enabled: viewStore.state.settings?.criticalAlertSetting == .enabled)
                  SettingRowView(
                    setting: "Siri Announcement?",
                    enabled: viewStore.state.settings?.announcementSetting == .enabled)
                }
            }
        }
        .onAppear{ viewStore.send(.onAppear)}
        }
    }
}

public struct SettingRowView: View {
  var setting: String
  var enabled: Bool
  public var body: some View {
    HStack {
      Text(setting)
      Spacer()
      if enabled {
        Image(systemName: "checkmark")
          .foregroundColor(.green)
      } else {
        Image(systemName: "xmark")
          .foregroundColor(.red)
      }
    }
    .padding()
  }
}
