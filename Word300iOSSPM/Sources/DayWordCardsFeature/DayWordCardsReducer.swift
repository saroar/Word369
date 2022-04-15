//
//  DayWordCardsReducer.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import SharedModels
import ComposableArchitecture
import DayWordCardFeature

public struct DayWordCardsEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.mainQueue = mainQueue
  }
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

    case let .word(id: id, action: action):
      switch action {
      case let .onChanged(value): return .none
      case let .onRemove(word):
        state.dayWordCardStates.removeAll(where: { $0.word == word })
        return .none
      case .getGesturePercentage(_, _): return .none
      }

    }
  }
)
