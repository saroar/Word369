//
//  CardAction.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import SharedModels

public enum DayWordCardAction {
  case onChanged(CGSize)
  case onRemove(_ word: Word)
  case getGesturePercentage(_ geometry: GeometryProxy, _ gesture: DragGesture.Value)
}
