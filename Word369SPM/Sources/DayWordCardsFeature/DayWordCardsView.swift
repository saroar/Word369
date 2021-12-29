//
//  DayWordCardsView.swift
//  
//
//  Created by Saroar Khandoker on 20.12.2021.
//

import SwiftUI
import SharedModels
import ComposableArchitecture

public struct DayWordCardsView: View {

  let store: Store<DayWordCardsState, DayWordCardsAction>
  @ObservedObject var viewStore: ViewStore<DayWordCardsState, DayWordCardsAction>

  public init(store: Store<DayWordCardsState, DayWordCardsAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    VStack {
      GeometryReader { geometry in
        VStack {
          ZStack {
            ForEachStore(
              self.store.scope(
                state: \DayWordCardsState.dayWordCardStates,
                action: DayWordCardsAction.word
              )
            ) { wordStore in
              DayWordCardView(store: wordStore)
                .padding()
                .animation(.spring())
                .frame(width: viewStore.getCardWidth, height: 400)
                .offset(x: 0, y: viewStore.getCardOffset)
                .onAppear {
                  viewStore.send(.getCardOffsetAndWidth(geometry))
                }
            }

          }

          Spacer()
        }
      }
    }
  }

}

struct DayWordCardsView_Previews: PreviewProvider {
  static var previews: some View {
    DayWordCardsView(
      store: Store(
        initialState: DayWordCardsState(),
        reducer: dayWordCardsReducer,
        environment: DayWordCardsEnvironment()
      )
    )
  }
}
