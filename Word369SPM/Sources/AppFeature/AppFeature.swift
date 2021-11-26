//
//  AppFeature.swift
//  
//
//  Created by Saroar Khandoker on 22.11.2021.
//

import ComposableArchitecture
import SwiftUI
import ComposableUserNotifications
import WordFeature
import WordClient
import SharedModels
import UserDefaultsClient

public enum AppState: Equatable {
  case welcome(WelcomeState)
  case word(WordState)
  public init() { self = .welcome(.init()) }
}

public enum AppAction: Equatable {
  case welcome(WelcomeAction)
  case word(WordAction)
  case userNotifications(UserNotificationClient.DelegateEvent)
  case scenePhase(ScenePhase)
}

public struct AppEnvironment {

  var userNotificationClient: UserNotificationClient
  var userDefaultsClient: UserDefaultsClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var backgroundQueue: AnySchedulerOf<DispatchQueue>

  public init(
    userNotificationClient: UserNotificationClient,
    userDefaultsClient: UserDefaultsClient,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.userNotificationClient = userNotificationClient
    self.userDefaultsClient = userDefaultsClient
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
  }

}

extension AppEnvironment {
  static public var live: AppEnvironment = .init(
    userNotificationClient: .live,
    userDefaultsClient: .live(),
    mainQueue: .main,
    backgroundQueue: .main
  )

  static public var mock: AppEnvironment = .init(
    userNotificationClient: .failing,
    userDefaultsClient: .noop,
    mainQueue: .immediate,
    backgroundQueue: .immediate
  )

}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  welcomeReducer.pullback(
        state: /AppState.welcome,
        action: /AppAction.welcome,
        environment: { _ in WelcomeEnvironment.live }
    ),
  wordReducer.pullback(
      state: /AppState.word,
      action: /AppAction.word,
      environment: { _ in WordEnvironment.live }
    ),
  .init {
    state, action, environment in

    switch action {
    case .welcome(.binding(\.$selectedPage)):
      return .none

    case .welcome(.moveToWordView):
      state = .word(.init())
      return .none

    case .welcome:

      if environment.userDefaultsClient
          .boolForKey(UserDefaultKeys.isWelcomeScreensFillUp.rawValue) == true {
        state = .word(.init())
        return .none
      }

      return .none
    case let .word(action):
      return .none
    case let .scenePhase(phase):
      switch phase {
      case .background: print(#line, "background")
        return .none
      case .inactive: print(#line, "inactive")
        return .none
      case .active: print(#line, "active")

        return .merge(
          // Set notifications delegate
          environment.userNotificationClient.delegate
            .map(AppAction.userNotifications),

          environment.userNotificationClient.getNotificationSettings
            .receive(on: environment.mainQueue)
            .flatMap { settings in
              [.notDetermined].contains(settings.authorizationStatus)
                ? environment.userNotificationClient.requestAuthorization([.alert, .sound])
                : settings.authorizationStatus == .authorized
                  ? environment.userNotificationClient.requestAuthorization([.alert, .sound])
                  : .none
            }
            .eraseToEffect()
            .fireAndForget()
          )
      @unknown default:
        print(#line, "default")
        return .none
      }

    case .userNotifications:
      return .none

    }
  }
)

public struct AppView: View {

  @Environment(\.scenePhase) private var scenePhase

  public let store: Store<AppState, AppAction>

  public init(store: Store<AppState, AppAction>) {
    self.store = store
  }

    public var body: some View {

      ZStack {
        SwitchStore(self.store) {
          CaseLet(state: /AppState.welcome, action: AppAction.welcome) { store in
            WelcomeView(store: store)
          }

          CaseLet(state: /AppState.word, action: AppAction.word) { store in
            NavigationView {
              WordView(store: store)
            }
            .stackNavigationViewStyle()
          }
        }
      }
      .onChange(of: scenePhase) { phase in
        ViewStore(store.stateless).send(.scenePhase(phase))
      }
    }
}
