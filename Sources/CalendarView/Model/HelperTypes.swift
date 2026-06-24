//
//  HelperTypes.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 02.07.2025.
//

public protocol PickerEnum: Hashable, Sendable, Codable, CaseIterable, RawRepresentable where AllCases: RandomAccessCollection, RawValue == String {
    var stringValue: String { get }
    static var title: String { get }
}

public extension PickerEnum {
    var stringValue: String { self.rawValue }
}

public enum RepeatType: String, PickerEnum {
    case never = "Never"
    case daily = "Every day"
    case workingDay = "Every working day"
    case weekend = "Every weekend"
    case weekly = "Every week"
    case twoWeekly = "Every 2 weeks"
    case monthly  = "Every month"
    case year = "Every year"

    static public var title: String { "Repeat" }
}

public enum AlertType: String, PickerEnum {
    case none = "None"
    case atTimeOfEvent = "At time of event"
    case before5Minutes = "5 minutes before"
    case before10Minutes = "10 minutes before"
    case before15Minutes = "15 minutes before"
    case before30Minutes = "30 minutes before"
    case before1hour = "1 hour before"
    case before2hour = "2 hours before"
    case before1day = "1 day before"
    case before2day = "2 days before"
    case before1week = "1 week before"

    static public var title: String { "Alert" }
}

public enum VibrationType: String, PickerEnum {
    case none = "None"
    case alert = "Alert"

    static public var title: String { "Vibration type" }
}

public enum PriorityType: String, PickerEnum {
    case none = "None"
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    static public var title: String { "Priority" }
}
