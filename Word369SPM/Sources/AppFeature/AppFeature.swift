//
//  AppFeature.swift
//  
//
//  Created by Saroar Khandoker on 22.11.2021.
//

import ComposableArchitecture
import SwiftUI

public struct AppState: Equatable {
  public init(
    welcomeState: WelcomeState = .init()
  ) {
    self.welcomeState = welcomeState
  }

  public var welcomeState: WelcomeState
}

public enum AppAction: Equatable {
  case welcome(WelcomeAction)
}

public struct AppEnvironment {}
extension AppEnvironment {
  static public var live: AppEnvironment = .init()
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  welcomeReducer
      .pullback(
          state: \.welcomeState,
          action: /AppAction.welcome,
          environment: { _ in WelcomeEnvironment() }
      ),
  .init {
    state, action, environment in
    switch action {
    case let .welcome(action):
      state.welcomeState = WelcomeState()
      return .none
    }
  }
)

public struct AppView: View {
    public let store: Store<AppState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    public var body: some View {
      WelcomeView(store: store.scope(
        state: { $0.welcomeState },
        action: AppAction.welcome)
      )
    }
}

