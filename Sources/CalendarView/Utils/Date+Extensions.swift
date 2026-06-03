//
//  DateUtils.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

public extension Date {

    // MARK: - Init & Format

    init?(sqlString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let date = formatter.date(from: sqlString) {
            self = date
        } else {
            return nil
        }
    }

    func formatted(_ format: String) -> String {
        DateFormatterCache.shared.string(from: self, withFormat: format)
    }

    func adding(_ component: Calendar.Component, value: Int) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func startOfWeek(_ firstDayOfWeek: Int?) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        let firstDayOfWeek = firstDayOfWeek ?? calendar.firstWeekday
        let daysToSubtract = (7 + weekday - firstDayOfWeek) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: self.startOfDay)!
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!.startOfDay
    }

    var startOfYear: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components)!.startOfDay
    }

    var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 0
    }

    var maxMonthDay: Int {
        let calendar = Calendar.current
        return calendar.range(of: .day, in: .month, for: self)?.count ?? 30
    }

    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }
    
    func getDateWithoutTime() -> Date? {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.timeZone = TimeZone.current
        return calendar.date(from: dateComponents)
    }
    
    func nextDay() -> Date? {
        Calendar.current.date(byAdding: .day, value: 1, to: self)
    }
    
    func previousDay() -> Date? {
        Calendar.current.date(byAdding: .day, value: -1, to: self)
    }

    var dateFullFormat: String {
        let dateFormatter = DateFormatter.dateFullFormatter
        return dateFormatter.string(from: self)
    }

    var dateFormat: String {
        let dateFormatter = DateFormatter.dateFormatter
        return dateFormatter.string(from: self)
    }

    var shortDateFormat: String {
        let dateFormatter = DateFormatter.shortDateFormatter
        return dateFormatter.string(from: self)
    }

    var timeFormat: String {
        let dateFormatter = DateFormatter.timeFormatter
        return dateFormatter.string(from: self)
    }

    // MARK: - Set Full Time or Date

    func setTime(to time: String) -> Date? {
        let components = time.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return nil }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var newComponents = calendar.dateComponents([.year, .month, .day], from: self)
        newComponents.hour = components[0]
        newComponents.minute = components[1]
        newComponents.second = 0
        return calendar.date(from: newComponents)
    }

    func setDay(to dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let newDay = formatter.date(from: dateString) else { return nil }
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: newDay)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        var merged = DateComponents()
        merged.year = dayComponents.year
        merged.month = dayComponents.month
        merged.day = dayComponents.day
        merged.hour = timeComponents.hour
        merged.minute = timeComponents.minute
        merged.second = timeComponents.second
        return calendar.date(from: merged)
    }

    // MARK: - Get Individual Components

    func getYear() -> Int {
        Calendar.current.dateComponents([.year], from: self).year!
    }

    func getMonth() -> Int {
        Calendar.current.dateComponents([.month], from: self).month!
    }

    func getDay() -> Int {
        Calendar.current.dateComponents([.day], from: self).day!
    }

    func getHour() -> Int {
        Calendar.current.dateComponents([.hour], from: self).hour!
    }

    func getMinute() -> Int {
        Calendar.current.dateComponents([.minute], from: self).minute!
    }

    func getSecond() -> Int {
        Calendar.current.dateComponents([.second], from: self).second!
    }

    func getWeekday() -> Int {
        Calendar.current.dateComponents([.weekday], from: self).weekday!
    }

    // MARK: - Set Individual Components

    func setYear(to year: Int) -> Date {
        updateComponent(.year, value: year)
    }

    func setMonth(to month: Int) -> Date {
        updateComponent(.month, value: month)
    }

    func setDayOfMonth(to day: Int) -> Date {
        updateComponent(.day, value: day)
    }

    func setHour(to hour: Int) -> Date {
        updateComponent(.hour, value: hour)
    }

    func setMinute(to minute: Int) -> Date {
        updateComponent(.minute, value: minute)
    }

    func setSecond(to second: Int) -> Date {
        updateComponent(.second, value: second)
    }

    // MARK: - Internal Helper

    private func updateComponent(_ component: Calendar.Component, value: Int) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: self
        )
        switch component {
        case .year:   components.year = value
        case .month:  components.month = value
        case .day:    components.day = value
        case .hour:   components.hour = value
        case .minute: components.minute = value
        case .second: components.second = value
        default: break
        }
        return calendar.date(from: components) ?? Date()
    }
}

final class DateFormatterCache: @unchecked Sendable {

	static let shared = DateFormatterCache()

	private let lock = NSLock()

	private var formatters: [String: DateFormatter] = [:]

    func formatter(for format: String) -> DateFormatter {
        if let existing = formatters[format] {
            return existing
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatters[format] = formatter
            return formatter
        }
    }

	func string(from date: Date, withFormat format: String) -> String {
		lock.lock()
		defer { lock.unlock() }
		return formatter(for: format).string(from: date)
	}
}

extension DateFormatter {
    static let dateFullFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .full
        formatter.timeStyle = .none

        return formatter
    }()

    static let dateFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter
    }()

    static let shortDateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "dd MMM"

        return formatter
    }()

    static let timeFormatter = {
        let formatter = DateFormatter()

        formatter.dateStyle = .none
        formatter.timeStyle = .short

        return formatter
    }()
}
