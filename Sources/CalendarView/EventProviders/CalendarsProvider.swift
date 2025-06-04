//
//  CalendarsProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

import SwiftUI

protocol CalendarsProvider: Sendable {
    func getEvents(from startDate: Date, to endDate: Date, selectedCalendarIDs: Set<String>) async throws -> [CalendarEvent]
    func getReminders(from startDate: Date, to endDate: Date, selectedCalendarIDs: Set<String>) async throws -> [CalendarReminder]

    func getCalendars() async throws -> [ProviderCalendar]
    func addCalendar()
}
