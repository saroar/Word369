//
//  DayWordCardsView.swift
//  
//
//  Created by Saroar Khandoker on 20.12.2021.
//

import SwiftUI
import SharedModels
import ComposableArchitecture
import DayWordCardFeature

public struct DayWordCardsView: View {

  let store: Store<DayWordCardsState, DayWordCardsAction>
  @ObservedObject var viewStore: ViewStore<DayWordCardsState, DayWordCardsAction>
  
  struct ViewState: Equatable {
    init(state: DayWordCardsState) {
      self.dayWordCardStates = state.dayWordCardStates
    }
    
    let dayWordCardStates: IdentifiedArrayOf<DayWordCardState>
  }

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
                  self.cardView(
                    store: wordStore,
                    cardCount: viewStore.dayWordCardStates.count,
                    geometry: geometry
                  )
              }
            }
            Spacer()
          }
      }
    }
  }

  func cardView(
    store: Store<DayWordCardState, DayWordCardAction>,
    cardCount: Int, geometry: GeometryProxy
  ) -> some View {
    
    WithViewStore(store.scope(state: \.id)) { viewStore in
      let id = viewStore.state
      let offset = CGFloat(cardCount - 1 - id) * 10
      let cardWidth = geometry.size.width - offset
      let cardOffset = CGFloat(cardCount - 1 - id) * 10
      
      DayWordCardView(store: store)
            .padding()
            .animation(.spring())
            .frame(width: cardWidth, height: 400)
            .offset(x: 0, y: cardOffset)
    }
    
  }

}

struct DayWordCardsView_Previews: PreviewProvider {
  static var previews: some View {
    DayWordCardsView(
      store: Store(
        initialState: DayWordCardsState(),
        reducer: dayWordCardsReducer,
        environment: DayWordCardsEnvironment(mainQueue: .immediate)
      )
    )
  }
}
