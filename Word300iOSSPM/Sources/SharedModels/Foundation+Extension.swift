//
//  Foundation+Extension.swift
//  
//
//  Created by Saroar Khandoker on 08.12.2021.
//

import Foundation

extension Date {
    public func adding(days: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = days

        return NSCalendar.current.date(byAdding: dateComponents, to: self)
    }
}

extension Date {
    public func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    public func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }

    public var hour: Int {
      return Calendar.current.component(.hour, from: self)
    }
    
    public var minute: Int {
      return Calendar.current.component(.minute, from: self)
    }
}
