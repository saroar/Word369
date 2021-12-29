//
//  WordView.swift
//  
//
//  Created by Saroar Khandoker on 24.11.2021.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import ComposableUserNotifications
import SharedModels
import HTTPRequestKit
import WordClient
import Combine
import DayWordCardsFeature

public struct WordView: View {
  
  let store: Store<WordState, WordAction>
  
  public init(store: Store<WordState, WordAction>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        DayWordCardsView(
          store: self.store.scope(
            state: \.dayWordCardState,
            action: WordAction.dayWords
          )
        )
      }
      .onAppear {
        viewStore.send(.onApper)
      }
    }
    .navigationTitle("Your words")
  }
}

struct WordView_Previews: PreviewProvider {
  
  static var store = Store(
    initialState: WordState.mock,
    reducer: wordReducer,
    environment: WordEnvironment.mock)
  
  static var previews: some View {
    WordView(store: store)
  }
}
