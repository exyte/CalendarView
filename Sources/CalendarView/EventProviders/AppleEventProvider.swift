//
//  AppleEventProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

@preconcurrency import EventKit
import SwiftUI

/// Fetches events from Apple's Calendar App. Will only fetch events from accounts which Calendar App has access to. If you'd like to add more accounts, add them in Calendar App.
final class AppleEventProvider: CalendarEventProvider {
    private let eventStore = EKEventStore()

    func getEvents(from startDate: Date, to endDate: Date) async throws -> [CalendarEvent] {
        try await requestAccessIfNeeded()

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)

        return ekEvents.map {
            CalendarEvent(
                id: $0.eventIdentifier,
                calendarID: $0.calendar.calendarIdentifier,
                title: $0.title ?? "Untitled",
                description: $0.description,
                startDate: $0.startDate,
                endDate: $0.endDate,
                isAllDay: $0.isAllDay,
                //priority: $0,
                //vibration: $0,
                isDetached: $0.isDetached)
        }
    }

    func getCalendars() async throws -> [ProviderCalendar] {
        try await requestAccessIfNeeded()

        return eventStore.calendars(for: .event).map {
            //$0.source.title
            ProviderCalendar(
                id: $0.calendarIdentifier,
                name: $0.title,
                color: Color(cgColor: $0.cgColor ?? UIColor.systemGray.cgColor)
            )
        }
    }

    private func requestAccessIfNeeded() async throws {
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .notDetermined:
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                if !granted {
                    print("Please add NSCalendarsFullAccessUsageDescription to your plist")
                }
            } catch {
                print(error.localizedDescription)
            }

        case .fullAccess:
            // All good, proceed.
            break

        default:
            throw CalendarAccessDenied()
        }
    }

    struct CalendarAccessDenied: Error {}
}
