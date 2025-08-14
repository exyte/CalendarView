//
//  CalendarsProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

import SwiftUI

public protocol CalendarsProvider: Sendable {
    func getCalendars() async throws -> [ProviderCalendar]
    func getEvents(from startDate: Date, to endDate: Date, selectedCalendarIDs: [String]) async throws -> [CalendarEvent]
    func getReminders(from startDate: Date, to endDate: Date, selectedCalendarIDs: [String]) async throws -> [CalendarReminder]
}

protocol EditableCalendarsProvider: CalendarsProvider {
    func addCalendar(_ calendar: ProviderCalendar) async throws
    func addEvent(_ event: CalendarEvent) async throws
    func addReminder(_ reminder: CalendarReminder) async throws

    func updateEvent(_ event: CalendarEvent, oldStartDate: Date) async throws
    func updateReminder(_ reminder: CalendarReminder, oldStartDate: Date) async throws
}
