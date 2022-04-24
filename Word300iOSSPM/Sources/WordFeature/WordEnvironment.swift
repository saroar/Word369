//
//  WordEnvironment.swift
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

public struct WordEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var userNotificationClient: UserNotificationClient
  public var userDefaultsClient: UserDefaultsClient
  public var wordClient: WordClient
  
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    userNotificationClient: UserNotificationClient,
    userDefaultsClient: UserDefaultsClient,
    wordClient: WordClient
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.userNotificationClient = userNotificationClient
    self.userDefaultsClient = userDefaultsClient
    self.wordClient = wordClient
  }
}

extension WordEnvironment {
  static public var live: WordEnvironment = .init(
    mainQueue: .main, backgroundQueue: .main,
    userNotificationClient: .live,
    userDefaultsClient: .live(),
    wordClient: .live
    
  )
  
  static public var mock: WordEnvironment = .init(
    mainQueue: .immediate, backgroundQueue: .immediate,
    userNotificationClient: .mock(),
    userDefaultsClient: .noop,
    wordClient: .live
  )
}
