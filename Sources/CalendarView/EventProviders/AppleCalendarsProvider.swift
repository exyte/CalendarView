//
//  AppleEventProvider.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

@preconcurrency import EventKit
import SwiftUI

/// Fetches events from Apple's Calendar App. Will only fetch events from accounts which Calendar App has access to. If you'd like to add more accounts, add them in Calendar App.
final class AppleCalendarsProvider: CalendarsProvider {
    private let eventStore = EKEventStore()

    func getEvents(from startDate: Date, to endDate: Date, selectedCalendarIDs: Set<String>) async throws -> [CalendarEvent] {
        try await requestAccessIfNeeded(.event)

        let calendars = eventStore.calendars(for: .event).filter { selectedCalendarIDs.contains($0.calendarIdentifier) }
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let ekEvents = eventStore.events(matching: predicate)

        return ekEvents.map {
            CalendarEvent(
                id: $0.eventIdentifier,
                calendarID: $0.calendar.calendarIdentifier,
                title: $0.title ?? "Untitled",
                notes: $0.description,
                calendarColor: Color(cgColor: $0.calendar.cgColor ?? UIColor.systemGray.cgColor),
                startDate: $0.startDate,
                endDate: $0.endDate,
                isAllDay: $0.isAllDay,
                //priority: $0,
                //vibration: $0,
                isDetached: $0.isDetached)
        }
    }

    func getReminders(from startDate: Date, to endDate: Date, selectedCalendarIDs: Set<String>) async throws -> [CalendarReminder] {
        try await requestAccessIfNeeded(.reminder)

        let calendars = eventStore.calendars(for: .reminder).filter { selectedCalendarIDs.contains($0.calendarIdentifier) }

        let incompletePredicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: startDate,
            ending: endDate,
            calendars: calendars
        )

        let completePredicate = eventStore.predicateForCompletedReminders(
            withCompletionDateStarting: startDate,
            ending: endDate,
            calendars: calendars
        )

        async let incomplete = fetch(incompletePredicate, isCompleted: false, from: startDate, to: endDate)
        async let complete = fetch(completePredicate, isCompleted: true, from: startDate, to: endDate)
        return try await incomplete + complete
    }

    func fetch(_ predicate: NSPredicate, isCompleted: Bool, from startDate: Date, to endDate: Date) async throws -> [CalendarReminder] {
        try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                let filtered = reminders?.filter {
                    guard let date = $0.dueDateComponents?.date else { return false }
                    return date >= startDate && date <= endDate
                } ?? []

                let result = filtered.map { reminder in
                    CalendarReminder(
                        id: reminder.calendarItemIdentifier,
                        calendarID: reminder.calendar.calendarIdentifier, title: reminder.title ?? "Untitled",
                        notes: reminder.notes,
                        calendarColor: Color(cgColor: reminder.calendar.cgColor ?? UIColor.systemGray.cgColor),
                        dueDate: reminder.dueDateComponents?.date ?? Date(),
                        isCompleted: isCompleted
                    )
                }

                continuation.resume(returning: result)
            }
        }
    }

    func getCalendars() async throws -> [ProviderCalendar] {
        try await requestAccessIfNeeded(.event)

        return eventStore.calendars(for: .event).map {
            let source = $0.type == .calDAV ? ($0.source?.title ?? "") : "Other"
            return ProviderCalendar(
                id: $0.calendarIdentifier,
                title: $0.title,
                source: source,
                color: Color(cgColor: $0.cgColor ?? UIColor.systemGray.cgColor)
            )
        }
    }

    func addCalendar() {
        DispatchQueue.main.async {
            UIApplication.shared.open(URL(string: "App-Prefs:root=CALENDARS")!)
        }
    }

    private func requestAccessIfNeeded(_ type: EKEntityType) async throws {
        let status = EKEventStore.authorizationStatus(for: type)

        switch status {
        case .notDetermined:
            do {
                switch type {
                case .event:
                    let granted = try await eventStore.requestFullAccessToEvents()
                    if !granted {
                        print("Please add NSCalendarsFullAccessUsageDescription to your plist")
                    }
                case .reminder:
                    let granted = try await eventStore.requestFullAccessToReminders()
                    if !granted {
                        print("Please add NSRemindersUsageDescription to your plist")
                    }
                @unknown default:
                    print("Unexpected EKEntityType value")
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

extension NSPredicate: @unchecked @retroactive Sendable { }
extension EKEventStore: @unchecked @retroactive Sendable { }
