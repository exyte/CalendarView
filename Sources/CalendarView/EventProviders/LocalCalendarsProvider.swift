//
//  LocalEventsProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 24.04.2025.
//

import SwiftUI

public final class LocalCalendarsProvider: EditableCalendarsProvider, @unchecked Sendable  {
    private let calendarStore = CodableStore<ProviderCalendar>()
    private let eventStore = CalendarEntityStore<CalendarEvent>()
    private let reminderStore = CalendarEntityStore<CalendarReminder>()

    public init() {}
    
    public func getCalendars() async throws -> [ProviderCalendar] {
        try await calendarStore.load()
    }

    public func getEvents(from startDate: Date, to endDate: Date, selectedCalendarIDs: [String]) async throws -> [CalendarEvent] {
        try await eventStore.events(from: startDate, to: endDate, calendarIDs: selectedCalendarIDs)
    }

    public func getReminders(from startDate: Date, to endDate: Date, selectedCalendarIDs: [String]) async throws -> [CalendarReminder] {
        try await reminderStore.events(from: startDate, to: endDate, calendarIDs: selectedCalendarIDs)
    }

    public func addCalendar(_ calendar: ProviderCalendar) async throws {
        var existing = await (try? calendarStore.load()) ?? []
        existing.append(calendar)
        try await calendarStore.save(existing)
    }

    public func addEvent(_ event: CalendarEvent) async throws {
        try await eventStore.add(event)
    }

    public func addReminder(_ reminder: CalendarReminder) async throws {
        try await reminderStore.add(reminder)
    }

    public func deleteEvent(_ event: CalendarEvent) async throws {
        try await eventStore.delete(id: event.id, calendarID: event.calendarID, from: event.startDate)
    }

    public func deleteReminder(_ reminder: CalendarReminder) async throws {
        try await reminderStore.delete(id: reminder.id, calendarID: reminder.calendarID, from: reminder.startDate)
    }

    public func updateEvent(_ event: CalendarEvent, oldCalendarID: String, oldStartDate: Date) async throws {
        try await eventStore.update(event, oldCalendarID: oldCalendarID, oldStartDate: oldStartDate)
    }

    public func updateReminder(_ reminder: CalendarReminder, oldCalendarID: String, oldStartDate: Date) async throws {
        try await reminderStore.update(reminder, oldCalendarID: oldCalendarID, oldStartDate: oldStartDate)
    }
}
