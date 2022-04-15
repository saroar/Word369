//
//  SwiftUI+Extension.swift
//  
//
//  Created by Saroar Khandoker on 08.12.2021.
//

import SwiftUI

extension View {
  @ViewBuilder
  public func stackNavigationViewStyle() -> some View {
    if #available(iOS 15.0, *) {
      self.navigationViewStyle(.stack)
    } else {
      self.navigationViewStyle(StackNavigationViewStyle())
    }
  }
}
