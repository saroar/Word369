//
//  DayWordCardsAction.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import SharedModels
import ComposableArchitecture
import DayWordCardFeature

public enum DayWordCardsAction: Equatable {
  case onAppear
  case word(id: Int, action: DayWordCardAction)
}
