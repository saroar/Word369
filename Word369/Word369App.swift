//
//  Word369App.swift
//  Word369
//
//  Created by Saroar Khandoker on 22.11.2021.
//

import SwiftUI
import AppFeature
import ComposableArchitecture

@main
struct Word369App: App {
  let store: Store<AppState, AppAction> = Store(
      initialState: .init(),
      reducer: appReducer.debug(),
      environment: .live
  )

  var body: some Scene {
      WindowGroup {
        AppView(store: store)
      }
  }
}
