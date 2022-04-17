//
//  WordView.swift
//  
//
//  Created by Saroar Khandoker on 24.11.2021.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import ComposableUserNotifications
import SharedModels
import HTTPRequestKit
import WordClient
import Combine
import DayWordCardsFeature
import SettingsFeature

public struct WordView: View {
    
    let store: Store<WordState, WordAction>
    
    public init(store: Store<WordState, WordAction>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        init(state: WordState) {
            self.dayWordCardState = state.dayWordCardState
            self.isSettingsNavigationActive = state.isSettingsNavigationActive
            self.isLoading = state.isLoading
        }
        
        let dayWordCardState: DayWordCardsState
        let isSettingsNavigationActive: Bool
        let isLoading: Bool
    }
    
    public var body: some View {
        
        WithViewStore(self.store.scope(state: ViewState.init)) { viewStore in
            VStack {
                if viewStore.isLoading { ProgressView() }

                DayWordCardsView(
                    store: self.store.scope(
                        state: \.dayWordCardState,
                        action: WordAction.dayWords
                    )
                ).redacted(reason: viewStore.isLoading ? .placeholder : .init())
            }
            .navigationBarItems(
                trailing: HStack {
                    Button {
                        viewStore.send(.settingsView(isNavigate: true))
                    } label: {
                        Image(systemName: "circle.hexagongrid.circle").imageScale(.large)
                    }
                }
            )
            .onAppear {
                viewStore.send(.onApper)
            }
            .background(
                NavigationLink(
                    destination: IfLetStore(
                        self.store.scope(state: \.settingsState, action: WordAction.settings),
                        then: SettingsView.init(store:),
                        else: ProgressView.init
                    ),
                    isActive: viewStore.binding(
                        get: \.isSettingsNavigationActive,
                        send:  WordAction.settingsView(isNavigate:)
                    )
                ) {}
            )
        }
    }
}

struct WordView_Previews: PreviewProvider {
    
    static var store = Store(
        initialState: WordState.mock,
        reducer: wordReducer,
        environment: WordEnvironment.mock)
    
    static var previews: some View {
        WordView(store: store)
    }
}
