//
//  WordReminder.swift
//  
//
//  Created by Кхандокер Сароар on 26.05.2022.
//

import Foundation

public struct WordReminder: Equatable, Identifiable, Hashable, Codable {
    
    public static func == (lhs: WordReminder, rhs: WordReminder) -> Bool {
        return lhs.hour == rhs.hour && lhs.date == rhs.date
    }
    
    public var id = 0
    public var hour: Int = 0
    public var date: Date = Calendar.current
        .date(bySettingHour: 8, minute: 00, second: 0, of: Date())!
    
    public init(id: Int = 0, hour: Int = 0, date: Date = Calendar.current
        .date(bySettingHour: 8, minute: 00, second: 0, of: Date())!) {
            self.id = id
            self.hour = hour
            self.date = date
        }
}

extension WordReminder {
    static let list: [WordReminder] = (8..<14).enumerated().map {
        .init(
            id: $0 + 1,
            hour: $1,
            date: Calendar.current
                .date(bySettingHour: $1, minute: 00, second: 0, of: Date())!
        )
    }
}
