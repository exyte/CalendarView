//
//  LocalEventsProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 24.04.2025.
//

import SwiftUI

/// Fetches events from Apple's Calendar App. Will only fetch events from accounts which Calendar App has access to. If you'd like to add more accounts, add them in Calendar App.
final class LocalCalendarsProvider: CalendarsProvider {
    func getEvents(from startDate: Date, to endDate: Date, selectedCalendarIDs: Set<String>) async throws -> [CalendarEvent] {
        Array([
            CalendarEvent(title: "Mom's BD", notes: "Don't forget to get her something nice", startDate: startDate.setTime(to: "10:00")!, endDate: startDate.setTime(to: "20:30")!),
            CalendarEvent(title: "Restaurant", startDate: startDate.setTime(to: "14:00")!, endDate: startDate.setTime(to: "16:00")!),
            CalendarEvent(title: "Bowling", startDate: startDate.setTime(to: "18:00")!, endDate: startDate.setTime(to: "21:00")!),
            CalendarEvent(title: "Water plants", startDate: startDate.setTime(to: "13:00")!),
            CalendarEvent(title: "Take medicine", startDate: startDate.setTime(to: "14:40")!),
            CalendarEvent(title: "Clean up", startDate: startDate.setTime(to: "22:00")!),
            CalendarEvent(title: "Read a book", startDate: startDate.setTime(to: "23:00")!),
            CalendarEvent(title: "Cook dinner", startDate: startDate.setTime(to: "23:00")!)
        ].prefix(startDate.getDay() % 8))
    }

    func getReminders(from startDate: Date, to endDate: Date, selectedCalendarIDs: Set<String>) async throws -> [CalendarReminder] {
        []
    }

    func getCalendars() async throws -> [ProviderCalendar] {
        [ProviderCalendar(id: "local", title: "local", source: "local", color: .gray)]
    }

    func addCalendar() {
        
    }
}
