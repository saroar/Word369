//
//  CardState.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import SharedModels

public struct DayWordCardState: Equatable, Identifiable {
  
  public var id: Int
  public var word: Word
  public var translation: CGSize = .zero
  public var getGesturePercentage: CGFloat = .zero
  
  public init(
    id: Int,
    word: Word,
    translation: CGSize = .zero,
    getGesturePercentage: CGFloat = .zero
  ) {
    self.id = id
    self.word = word
    self.translation = translation
    self.getGesturePercentage = getGesturePercentage
  }
  
}
