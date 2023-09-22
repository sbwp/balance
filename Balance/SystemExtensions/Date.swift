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
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    var percentRemainingInDay: Double {
        return distance(to: endOfDay) / 86_400 // 86_400 is number of seconds in a day
    }
    
    func addDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: days), to: self)!
    }
    
    func addHours(_ hours: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(hour: hours), to: self)!
    }
    
    func setTime(hour: Int, minute: Int = 0, second: Int = 0, nanosecond: Int = 0) -> Date {
        return setHour(hour).setMinute(minute).setSecond(second).setNanosecond(nanosecond)
    }
    
    func setHour(_ hour: Int) -> Date {
        return Calendar.current.date(bySetting: .hour, value: hour, of: self)!
    }
    
    func setMinute(_ minute: Int) -> Date {
        return Calendar.current.date(bySetting: .minute, value: minute, of: self)!
    }
    
    func setSecond(_ second: Int) -> Date {
        return Calendar.current.date(bySetting: .second, value: second, of: self)!
    }
    
    func setNanosecond(_ nanosecond: Int) -> Date {
        return Calendar.current.date(bySetting: .nanosecond, value: nanosecond, of: self)!
    }
    
    func isSameDayAs(_ other: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    func distanceInDays(to other: Date) -> Int? {
        let from = self < other ? self : other
        let to = self < other ? other : self
        return Calendar.current.dateComponents([.day], from: from , to: to).day
    }
}
