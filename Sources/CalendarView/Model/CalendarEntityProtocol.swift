//
//  CalendarEntityProtocol.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 30.05.2025.
//

import SwiftUI

public enum EntityType: String, Sendable, CaseIterable {
    case event, reminder
}

public protocol CalendarEntity: Equatable, Identifiable, Sendable, Codable {
    var id: String { get }
    var calendarID: String { get set }

    var title: String { get set }
    var notes: String { get set }
    var calendarColor: Color { get set }
    var calendarName: String { get set }
    var startDate: Date { get set }

    var repeatType: RepeatType { get set }
    var alertType: AlertType { get set }
    var priorityType: PriorityType { get set }
    var vibrationType: VibrationType { get set }

    var type: EntityType { get }
    var typeString: String { get }
    var isLocalEntity: Bool { get }

    func repeatableEventOccursOn(date: Date) -> Bool
    mutating func stripTime()
}

extension CalendarEntity {
    public mutating func stripTime() {}
    public func repeatableEventOccursOn(date: Date) -> Bool {
        guard repeatType != .never else { return false }
        guard date >= startDate.startOfDay else { return false }

        switch repeatType {
        case .never:
            return false
        case .daily:
            return true
        case .workingDay:
            return !date.isWeekend
        case .weekend:
            return date.isWeekend
        case .weekly:
            return date.getWeekday() == startDate.getWeekday()
        case .twoWeekly:
            let days = Calendar.current.dateComponents([.day], from: startDate.startOfDay, to: date.startOfDay).day ?? 0
            return days >= 0 && days % 14 == 0
        case .monthly:
            return date.getDay() == startDate.getDay()
        case .year:
            return date.getMonth() == startDate.getMonth()
                && date.getDay() == startDate.getDay()
        }
    }

    public var typeString: String {
        type.rawValue.capitalized
    }

    public var isLocalEntity: Bool {
        id.hasPrefix(Self.localIDPrefix)
    }

    public static var localIDPrefix: String { "Local-" }
    public static func newLocalID() -> String { "\(localIDPrefix)\(UUID().uuidString)" }
}


