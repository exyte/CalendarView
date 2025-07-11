//
//  LocalEventsProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 24.04.2025.
//

import SwiftUI

public final actor LocalCalendarsProvider: EditableCalendarsProvider {
    private let calendarStore = CodableStore<ProviderCalendar>()
    private let eventStore = CalendarEntityStore<CalendarEvent>()
    private let reminderStore = CalendarEntityStore<CalendarReminder>()

    public func getCalendars() async throws -> [ProviderCalendar] {
        try await calendarStore.load()
    }

    public func getEvents(from startDate: Date, to endDate: Date, selectedCalendarIDs: [String]) async throws -> [CalendarEvent] {
        try await eventStore.events(from: startDate, to: endDate, calendarIDs: selectedCalendarIDs)
    }

    public func getReminders(from startDate: Date, to endDate: Date, selectedCalendarIDs: [String]) async throws -> [CalendarReminder] {
        try await reminderStore.events(from: startDate, to: endDate, calendarIDs: selectedCalendarIDs)
    }

    public func addCalendar(_ calendar: ProviderCalendar) {
        Task {
            var existing = await (try? calendarStore.load()) ?? []
            existing.append(calendar)
            try await calendarStore.save(existing)
        }
    }

    func addEvent(_ event: CalendarEvent) {
        Task {
            try await eventStore.add(event)
        }
    }

    func addReminder(_ reminder: CalendarReminder) {
        Task {
            try await reminderStore.add(reminder)
        }
    }

    func updateEvent(_ event: CalendarEvent, oldStartDate: Date) {
        Task {
            try await eventStore.update(event, oldStartDate: oldStartDate)
        }
    }

    func updateReminder(_ reminder: CalendarReminder, oldStartDate: Date) {
        Task {
            try await reminderStore.update(reminder, oldStartDate: oldStartDate)
        }
    }
}
