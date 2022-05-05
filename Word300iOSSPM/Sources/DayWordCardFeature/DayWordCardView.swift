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

    fileprivate func english() -> some View {
        Group {
            Text("\(viewStore.word.englishTitle)")
                .font(.title).bold()
                .foregroundColor(.black)
                .padding([.top, .leading, .trailing], 16)
            
            Text("\(viewStore.word.englishDefinition)")
                .font(.body)
                .foregroundColor(.black)
                .padding([.bottom, .leading, .trailing], 16)
        }
    }
    
    fileprivate func russian() -> some View {
        Group {
            Text("\(viewStore.word.russianTitle ?? "")")
                .font(.title).bold()
                .foregroundColor(.black)
                .padding([.top, .leading, .trailing], 16)
            Text("\(viewStore.word.russianDefinition ?? "")")
               .font(.body)
               .foregroundColor(.black)
               .padding([.bottom, .leading, .trailing], 16)
        }
    }
    
    fileprivate func bangla() -> some View {
        Group {
            Text("\(viewStore.word.banglaTitle ?? "")")
                .font(.title).bold()
                .foregroundColor(.black)
                .padding([.top, .leading, .trailing], 16)
            Text("\(viewStore.word.banglaDefinition ?? "")")
               .font(.body)
               .foregroundColor(.black)
               .padding([.bottom, .leading, .trailing], 16)
        }
    }
    
    public var body: some View {
    // 1
    GeometryReader { geometry in
      VStack(alignment: .leading) {
          if viewStore.from == "english" {
              english()
              Divider()
              if viewStore.to == "russian" {
                  russian()
              }
              
              if viewStore.to == "bangla" {
                  bangla()
              }
          }
          
          if viewStore.from == "russian" {
              russian()
              Divider()
              
              if viewStore.from == "english" {
                  english()
              }
              
              if viewStore.from == "bangla" {
                  bangla()
              }

          }
          
          if viewStore.from == "bangla" {
              bangla()
              
              Divider()
              
              if viewStore.from == "english" {
                  english()
              }
              
              if viewStore.from == "russian" {
                  russian()
              }
          }
        

          // Image(systemName: "person")
          //   .resizable()
          //   .aspectRatio(contentMode: .fit)
          //   .padding()
          //   .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
          //   .clipped()
          
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
