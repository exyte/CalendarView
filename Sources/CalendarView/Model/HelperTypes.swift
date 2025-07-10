//
//  HelperTypes.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 02.07.2025.
//

public protocol PickerEnum: Hashable, Sendable, Codable, CaseIterable, RawRepresentable where AllCases: RandomAccessCollection, RawValue == String {
    var stringValue: String { get }
    var title: String { get }
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

    public var title: String { "Repeat" }
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

    public var title: String { "Alert" }
}

public enum VibrationType: String, PickerEnum {
    case none = "None"
    case alert = "Alert"

    public var title: String { "Vibration type" }
}

public enum PriorityType: String, PickerEnum {
    case none = "None"
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    public var title: String { "Priority" }

//    var backgroundColor: Color {
//        switch self {
//        case .low:
//            return Color.priorityLowBackground
//        case .medium:
//            return .priorityMediumBackground
//        case .high:
//            return .priorityHighBackground
//        case .none:
//            return .policeBlue.opacity(0.1)
//        }
//    }
//
//    var foregroundColor: Color {
//        switch self {
//        case .low:
//            return Color.priorityLowForeground
//        case .medium:
//            return .priorityMediumForeground
//        case .high:
//            return .priorityHighForeground
//        case .none:
//            return .policeBlue
//        }
//    }
}
