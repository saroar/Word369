//
//  CardReducer.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import SharedModels


public struct DayWordCardEnvironment {
  public init() {}
}

public let dayWordCardReducer = Reducer<DayWordCardState, DayWordCardAction, DayWordCardEnvironment> { state, action, environment in
  switch action {
  case let .onRemove(user):
    return .none

  case let .onChanged(cgSize):
    state.translation = cgSize

    return .none

  case let .getGesturePercentage(geometry, gesture):
    state.getGesturePercentage = gesture.translation.width / geometry.size.width

    if abs(state.getGesturePercentage) > 0.5 {
      return Effect(value: DayWordCardAction.onRemove(state.word))
        .receive(on: DispatchQueue.main)
        .eraseToEffect()
    } else {
      return Effect(value: DayWordCardAction.onChanged(.zero))
        .receive(on: DispatchQueue.main)
        .eraseToEffect()
    }
  }
}
