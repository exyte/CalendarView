//
//  CalendarReminder.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.05.2025.
//

import SwiftUI

public struct CalendarReminder: CalendarEntity {
    public let id: String
    public var calendarID: String

    public var title: String
    public var notes: String
    public var calendarColor: Color
    public var startDate: Date
    public var isCompleted: Bool

    public var repeatType: RepeatType
    public var alertType: AlertType
    public var priorityType: PriorityType
    public var vibrationType: VibrationType

    public var entityType: EntityType { .reminder }

    init(id: String = UUID().uuidString, calendarID: String = "local", title: String = "", notes: String = "", calendarColor: Color = .gray, startDate: Date = Date(), isCompleted: Bool = false, repeatType: RepeatType = .never, alertType: AlertType = .atTimeOfEvent, priorityType: PriorityType = .none, vibrationType: VibrationType = .none) {
        self.id = id
        self.calendarID = calendarID
        self.title = title
        self.notes = notes
        self.calendarColor = calendarColor
        self.startDate = startDate
        self.isCompleted = isCompleted
        self.repeatType = repeatType
        self.alertType = alertType
        self.priorityType = priorityType
        self.vibrationType = vibrationType
    }
}
