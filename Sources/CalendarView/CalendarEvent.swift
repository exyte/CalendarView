//
//  CalendarEvent.swift
//
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI
import EventKit

public struct CalendarEvent: Identifiable, Sendable {
    public enum Priority: String {
        case low, normal, high
    }

    public init(id: String = UUID().uuidString, calendarID: String = "local", title: String, description: String? = nil, calendarColor: Color = .gray, startDate: Date, endDate: Date? = nil, isAllDay: Bool = false, priority: Priority = .normal, vibration: UIImpactFeedbackGenerator.FeedbackStyle = .light, isDetached: Bool = false, payload: [String : Codable] = [:]) {
        self.id = id
        self.calendarID = calendarID
        self.title = title
        self.description = description
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
    public var description: String?
    public var calendarColor: Color
    public var startDate: Date
    public var endDate: Date
    public var isAllDay: Bool
    public var priority: Priority
    public var vibration: UIImpactFeedbackGenerator.FeedbackStyle
    public var isDetached: Bool
    public var payload: [String: Codable]

    var duration: CGFloat { // in seconds
        endDate.timeIntervalSinceNow - startDate.timeIntervalSinceNow
    }

    func toString() -> String {
        title + startDate.formatted(" HH:mm") + endDate.formatted(" - HH:mm")
    }
}

struct ProviderCalendar: Identifiable, Sendable {
    let id: String
    let title: String
    let source: String
    let color: Color
}

struct DateInterval {
    var start: Date
    var end: Date
}
