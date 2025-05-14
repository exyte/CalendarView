//
//  CalendarEventProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

import SwiftUI

protocol CalendarEventProvider: Sendable {
    func getEvents(from startDate: Date, to endDate: Date, selectedCalendarIDs: Set<String>) async throws -> [CalendarEvent]

    func getCalendars() async throws -> [ProviderCalendar]
    func addCalendar()
}
