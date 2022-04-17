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
