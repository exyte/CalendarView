//
//  CalendarEntityProtocol.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 30.05.2025.
//

import SwiftUI

public enum EntityType: Sendable {
    case event, reminder
}

public protocol CalendarEntity: Equatable, Identifiable, Sendable, Codable {
    var id: String { get }
    var calendarID: String { get set }

    var title: String { get set }
    var notes: String { get set }
    var calendarColor: Color { get set }
    var startDate: Date { get set }

    var repeatType: RepeatType { get set }
    var alertType: AlertType { get set }
    var priorityType: PriorityType { get set }
    var vibrationType: VibrationType { get set }

    var entityType: EntityType { get }

    func repeatableEventOccursOn(date: Date) -> Bool
}

extension CalendarEntity {
    public func repeatableEventOccursOn(date: Date) -> Bool {
        guard repeatType != .never else { return false }
        var isSameDay: Bool = false

        switch repeatType {
        case .never:
            isSameDay = false
        case .daily:
            isSameDay = true
        case .workingDay:
            isSameDay = false
        case .weekend:
            isSameDay = false
        case .weekly:
            isSameDay = date.getWeekday() == startDate.getWeekday()
        case .twoWeekly:
            isSameDay = false
        case .monthly:
            isSameDay = date.getDay() == startDate.getDay()
        case .year:
            isSameDay = date.getMonth() == startDate.getMonth() &&
            date.getDay() == startDate.getDay()
        }

        return isSameDay
    }
}


