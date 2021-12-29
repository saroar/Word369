//
//  DayWordCardsAction.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import SharedModels
import ComposableArchitecture

public enum DayWordCardsAction {
  case onAppear
  case word(id: Word.ID, action: DayWordCardAction)
  case getCardOffsetAndWidth(_ geometry: GeometryProxy)
  case getCardWidth(_ width: CGFloat, _ offset: CGFloat)
  case getCardOffset( _ offset: CGFloat)
}
