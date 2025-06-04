//
//  CalendarReminder.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.05.2025.
//

import SwiftUI

public struct CalendarReminder: CalendarEntity {
    public let id: String
    public let calendarID: String

    public let title: String
    public let notes: String?
    public let calendarColor: Color
    public let dueDate: Date
    public let isCompleted: Bool

    public var startDate: Date { dueDate }
    public var entityType: EntityType { .reminder }
}
