//
//  CardState.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import SharedModels

public struct DayWordCardsState: Equatable {
  public init(
    dayWordCardStates: IdentifiedArrayOf<DayWordCardState> = [],
    getCardOffset: CGFloat = .zero,
    getCardWidth: CGFloat = CGFloat(300),
    increaseID: Int = 0, translation: CGSize = .zero
  ) {
    self.dayWordCardStates = dayWordCardStates
    self.getCardOffset = getCardOffset
    self.getCardWidth = getCardWidth
    self.increaseID = increaseID
    self.translation = translation
  }
  
  public var dayWordCardStates: IdentifiedArrayOf<DayWordCardState> = []
  public var getCardOffset: CGFloat = .zero
  public var getCardWidth: CGFloat = CGFloat(300)
  public var increaseID: Int = 0
  public var translation: CGSize = .zero
}
