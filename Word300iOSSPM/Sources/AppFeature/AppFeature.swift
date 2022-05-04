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
import DayWordCardsFeature

public enum AppState: Equatable {
  case welcome(WelcomeState)
  case word(WordState)
  public init() { self = .welcome(.init()) }
}

public enum AppAction {
  case welcome(WelcomeAction)
  case word(WordAction)
  case userNotifications(UserNotificationClient.Action)
  case requestAuthorizationResponse(Result<Bool, UserNotificationClient.Error>)
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
    userNotificationClient: .mock(),
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
      state = .word(.init(dayWordCardState: DayWordCardsState.init()))
        return .none

    case .welcome:

      if environment.userDefaultsClient
          .boolForKey(UserDefaultKeys.isWelcomeScreensFillUp.rawValue) == true {
        state = .word(.init(dayWordCardState: DayWordCardsState.init()))
        return .none
      }

      return .none

    case let .word(action):
      return .none
        
    case .userNotifications:
      return .none
        
    case let .scenePhase(phase):
      switch phase {
      case .background: debugPrint(#line, "background")
        return .none
      case .inactive: debugPrint(#line, "inactive")
        return .none
      case .active: debugPrint(#line, "active")
          
          return .merge(
            environment.userNotificationClient
              .delegate()
              .map(AppAction.userNotifications),
            
            environment.userNotificationClient.requestAuthorization([.alert, .badge, .sound])
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(AppAction.requestAuthorizationResponse)
        )
          
      @unknown default:
        debugPrint(#line, "default")
        return .none
      }
    case .requestAuthorizationResponse:
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
                .navigationTitle("Your words")
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
