//
//  WordAction.swift
//  
//
//  Created by Saroar Khandoker on 29.12.2021.
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

public enum WordAction {
  case onApper
  
  case wordResponse(Result<[Word], HTTPRequest.HRError>)
  
  case receiveUserDefaultsWords(Result<[Word], Never>)
  
  case requestDayWords([Word])
  case receiveDayWords(Result<[DayWords], NSError>)
  
  case userNotifications(UserNotificationClient.DelegateEvent)
  
  case dayWords(DayWordCardsAction)
  case settings(SettingsAction)
  case settingsView(isNavigate: Bool)
  
}
