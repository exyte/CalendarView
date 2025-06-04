//
//  CalendarEvent.swift
//
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

public struct CalendarEvent: CalendarEntity {
    public enum Priority: String, Sendable {
        case low, normal, high
    }

    public init(id: String = UUID().uuidString, calendarID: String = "local", title: String, notes: String? = nil, calendarColor: Color = .gray, startDate: Date, endDate: Date? = nil, isAllDay: Bool = false, priority: Priority = .normal, vibration: UIImpactFeedbackGenerator.FeedbackStyle = .light, isDetached: Bool = false, payload: [String : Sendable] = [:]) {
        self.id = id
        self.calendarID = calendarID
        self.title = title
        self.notes = notes
        self.calendarColor = calendarColor
        self.startDate = startDate
        self.endDate = endDate ?? startDate.adding(.hour, value: 1)
        self.isAllDay = isAllDay
        self.priority = priority
        self.vibration = vibration
        self.isDetached = isDetached
        self.payload = payload
    }

    public let id: String
    public let calendarID: String

    public var title: String
    public var notes: String?
    public var calendarColor: Color
    public var startDate: Date
    public var endDate: Date
    public var isAllDay: Bool
    public var priority: Priority
    public var vibration: UIImpactFeedbackGenerator.FeedbackStyle
    public var isDetached: Bool
    public var payload: [String: Sendable]

    public var entityType: EntityType { .event }

    public var duration: CGFloat { // in seconds
        endDate.timeIntervalSinceNow - startDate.timeIntervalSinceNow
    }

    func toString() -> String {
        title + startDate.formatted(" HH:mm") + endDate.formatted(" - HH:mm")
    }
}
