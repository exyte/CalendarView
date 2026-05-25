//
//  CalendarEvent.swift
//
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

public struct CalendarEvent: CalendarEntity, Hashable {
    public let id: String
    public var calendarID: String

    public var title: String
    public var notes: String
    public var calendarColor: Color
    public var calendarName: String
    public var startDate: Date
    public var endDate: Date
    public var isAllDay: Bool
    public var isDetached: Bool

    public var repeatType: RepeatType
    public var alertType: AlertType
    public var priorityType: PriorityType
    public var vibrationType: VibrationType

    public var entityType: EntityType { .event }

    public var duration: CGFloat { // in seconds
        endDate.timeIntervalSinceNow - startDate.timeIntervalSinceNow
    }

    public init(id: String = "Local-\(UUID().uuidString)", calendarID: String = "", title: String = "", notes: String = "", calendarColor: Color = .gray, calendarName: String = "", startDate: Date = Date(), endDate: Date? = nil, isAllDay: Bool = false, isDetached: Bool = false, repeatType: RepeatType = .never, alertType: AlertType = .none, priorityType: PriorityType = .none, vibrationType: VibrationType = .none, payload: [String : Sendable] = [:]) {
        self.id = id
        self.calendarID = calendarID
        self.title = title
        self.notes = notes
        self.calendarColor = calendarColor
        self.calendarName = calendarName
        self.startDate = startDate
        self.endDate = endDate ?? startDate.adding(.hour, value: 1)
        self.isAllDay = isAllDay
        self.isDetached = isDetached
        self.repeatType = repeatType
        self.alertType = alertType
        self.priorityType = priorityType
        self.vibrationType = vibrationType
    }

    func toString() -> String {
        title + startDate.formatted(" HH:mm") + endDate.formatted(" - HH:mm")
    }
}

extension UIImpactFeedbackGenerator.FeedbackStyle: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)
        guard let style = UIImpactFeedbackGenerator.FeedbackStyle(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid raw value for FeedbackStyle: \(rawValue)")
        }
        self = style
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
