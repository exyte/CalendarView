//
//  LocalEventsProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 24.04.2025.
//

import SwiftUI

/// Fetches events from Apple's Calendar App. Will only fetch events from accounts which Calendar App has access to. If you'd like to add more accounts, add them in Calendar App.
final class LocalEventsProvider: CalendarEventProvider {
    func getEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEvent] {
        [
            CalendarEvent(title: "Mom's BD", description: "Don't forget to get her something nice", startDate: .now.setTime(to: "10:00")!, endDate: .now.setTime(to: "20:30")!),
            CalendarEvent(title: "Restaurant", startDate: .now.setTime(to: "14:00")!, endDate: .now.setTime(to: "16:00")!),
            CalendarEvent(title: "Bowling", startDate: .now.setTime(to: "18:00")!, endDate: .now.setTime(to: "21:00")!),
            CalendarEvent(title: "Water plants", startDate: .now.setTime(to: "13:00")!),
            CalendarEvent(title: "Take medicine", startDate: .now.setTime(to: "14:40")!),
            CalendarEvent(title: "Clean up", startDate: .now.setTime(to: "22:00")!),
            CalendarEvent(title: "Read a book", startDate: .now.setTime(to: "23:00")!),
            CalendarEvent(title: "Cook dinner", startDate: .now.setTime(to: "23:00")!)
        ]
    }

    func getCalendars() async throws -> [ProviderCalendar] {
        [ProviderCalendar(id: "local", name: "local", color: .green)]
    }

    func addCalendar() {
        UIApplication.shared.open(URL(string: "App-Prefs:root=CALENDARS")!)
    }
}
