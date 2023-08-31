//
//  Date.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import Foundation

extension Date {
    static var today: Date {
        return Date().startOfDay
    }
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        addDays(1).startOfDay
    }
    
    var relativeString: String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.doesRelativeDateFormatting = true
        return relativeDateFormatter.string(from: self)
    }
    
    var isTodayOrFuture: Bool {
        return endOfDay > Date().startOfDay
    }
    
    var isYesterdayOrEarlier: Bool {
        return !isTodayOrFuture
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var percentRemainingInDay: Double {
        return distance(to: endOfDay) / 86_400 // 86_400 is number of seconds in a day
    }
    
    func addDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: days), to: self)!
    }
    
    func isSameDayAs(_ other: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: other)
    }
}
