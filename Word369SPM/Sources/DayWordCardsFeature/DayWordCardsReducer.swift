//
//  DayWordCardsReducer.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import SharedModels
import ComposableArchitecture

public struct DayWordCardsEnvironment {
  public init() {}
}

public let dayWordCardsReducer = Reducer<DayWordCardsState, DayWordCardsAction, DayWordCardsEnvironment>.combine(
  dayWordCardReducer.forEach(
    state: \.dayWordCardStates,
    action: /DayWordCardsAction.word(id:action:),
    environment: { _ in DayWordCardEnvironment() }
  ), Reducer { state, action, environment in

    switch action {

    case .onAppear:
      return .none

    case let .getCardOffsetAndWidth(geometry):
      state.increaseID += 1

      let offset = CGFloat(state.dayWordCardStates.count - 1 - state.increaseID) * 10

      return .merge(
        Effect(value: DayWordCardsAction.getCardWidth(geometry.size.width, offset))
          .receive(on: DispatchQueue.main)
          .eraseToEffect(),

        Effect(value: DayWordCardsAction.getCardOffset(offset))
          .receive(on: DispatchQueue.main)
          .eraseToEffect()
      )

    case let .getCardWidth(width, offset):
      state.getCardWidth = width - offset
      print(#line, state.getCardWidth, state.increaseID)

      return .none
    case let .getCardOffset(offset):
      state.getCardOffset = offset
      print(#line, state.getCardOffset, state.increaseID)

      return .none
    case let .word(id: id, action: action):
      switch action {
      case let .onChanged(value): return .none
      case let .onRemove(word):
        state.dayWordCardStates.removeAll(where: { $0.word == word })
        return .none
      case .getGesturePercentage(_, _): return .none
      }

    }
  })
