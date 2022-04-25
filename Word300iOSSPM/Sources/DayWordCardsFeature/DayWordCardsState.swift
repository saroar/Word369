//
//  CardState.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import SharedModels
import DayWordCardFeature

public struct DayWordCardsState: Equatable {
  public init(
    dayWordCardStates: IdentifiedArrayOf<DayWordCardState> = []
  ) {
    self.dayWordCardStates = dayWordCardStates
  }
  
  public var dayWordCardStates: IdentifiedArrayOf<DayWordCardState> = []

}

extension DayWordCardsState {
    public static let mockCardsState:  DayWordCardsState = .init(
        dayWordCardStates: [
            .init(id: 0, word: Word.mockDatas[0]),
            .init(id: 1, word: Word.mockDatas[1]),
            .init(id: 2, word: Word.mockDatas[2])
        ]
    )
}
