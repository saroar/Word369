//
//  Interface.swift
//  
//
//  Created by Saroar Khandoker on 06.12.2021.
//

import ComposableArchitecture
import Foundation

public struct UserDefaultsClient {

  public var boolForKey: (String) -> Bool
  public var dataForKey: (String) -> Data?
  public var doubleForKey: (String) -> Double
  public var integerForKey: (String) -> Int
  public var stringForKey: (String) -> String?

  public var remove: (String) -> Effect<Never, Never>
  public var setBool: (Bool, String) -> Effect<Never, Never>
  public var setData: (Data?, String) -> Effect<Never, Never>
  public var setDouble: (Double, String) -> Effect<Never, Never>
  public var setInteger: (Int, String) -> Effect<Never, Never>
  public var setString: (String, String) -> Effect<Never, Never>

}
