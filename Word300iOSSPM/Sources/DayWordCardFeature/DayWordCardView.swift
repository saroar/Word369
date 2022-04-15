//
//  SwiftUIView.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
//

import SwiftUI
import ComposableArchitecture
import SharedModels

public struct DayWordCardView: View {

  let store: Store<DayWordCardState, DayWordCardAction>
  @ObservedObject var viewStore: ViewStore<DayWordCardState, DayWordCardAction>

  public init(store: Store<DayWordCardState, DayWordCardAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  public var body: some View {
    // 1
    GeometryReader { geometry in
      VStack(alignment: .leading) {
          
          Text("\(viewStore.word.englishTitle)")
              .font(.title).bold()
              .padding([.top, .leading, .trailing], 16)
          Text("\(viewStore.word.englishDefinition)")
              .font(.body)
              .padding([.bottom, .leading, .trailing], 16)
        Divider()
          // 5
          // Image(systemName: "person")
          //   .resizable()
          //   .aspectRatio(contentMode: .fit)
          //   .padding()
          //   .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
          //   .clipped()
        
          Text("\(viewStore.word.russianTitle ?? "")")
              .font(.title).bold()
              .padding([.top, .leading, .trailing], 16)
          Text("\(viewStore.word.russianDefinition ?? "")")
             .font(.body)
             .padding([.bottom, .leading, .trailing], 16)
          Spacer()
//        HStack {
//          // 5
//          VStack(alignment: .leading, spacing: 6) {
//
//            Text("")
//              .font(.subheadline)
//              .bold()
//
//          }
//          Spacer()
//
//          Image(systemName: "info.circle")
//            .foregroundColor(.gray)
//        }
//        .padding(.horizontal)
      }
      .padding(.bottom)
      .background(Color.white)
      .cornerRadius(10)
      .shadow(radius: 5)
      .offset(x: viewStore.translation.width, y: viewStore.translation.height)
      .animation(.interactiveSpring())
      .rotationEffect(
        .degrees(Double(viewStore.translation.width / geometry.size.width) * 25),
        anchor: .bottom
      )
      .gesture(
        DragGesture()
          .onChanged { value in
            viewStore.send(.onChanged(value.translation))
          }.onEnded { value in
            viewStore.send(.getGesturePercentage(geometry, value))
          }
      )
    }
  }
}
