//
//  CalendarViewModel.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

import Observation
import Foundation

@Observable
@MainActor
class CalendarViewModel {
    public var events: [CalendarEvent] = []
    public var reminders: [CalendarReminder] = []
    public var calendars: [ProviderCalendar] = []
    public var selectedCalendarIDs: Set<String> = []

    private let eventProviders: [CalendarsProvider] = [AppleCalendarsProvider(), LocalCalendarsProvider()]
    private var calendarStore = CalendarSelectionStore()

    func fetch(_ interval: DateInterval) async {
        // user explicitly deselected all of his calendards
        if calendarStore.selectedIDsExists && calendarStore.selectedIDs.isEmpty {
            events = []
            reminders = []
            return
        }

        var resultE = [CalendarEvent]()
        for eventProvider in eventProviders {
            if let providerResult = try? await eventProvider.getEvents(from: interval.start, to: interval.end, selectedCalendarIDs: calendarStore.selectedIDs) {
                resultE.append(contentsOf: providerResult)
            }
        }
        events = resultE

        var resultR = [CalendarReminder]()
        for eventProvider in eventProviders {
            if let providerResult = try? await eventProvider.getReminders(from: interval.start, to: interval.end, selectedCalendarIDs: calendarStore.selectedIDs) {
                resultR.append(contentsOf: providerResult)
            }
        }
        reminders = resultR
    }

    func fetchCalendars() async {
        var result = [ProviderCalendar]()
        for eventProvider in eventProviders {
            if let providerResult = try? await eventProvider.getCalendars() {
                result.append(contentsOf: providerResult)
            }
        }
        calendars = result
        calendarStore.initializeIfNeeded(with: calendars.map(\.id))
        selectedCalendarIDs = calendarStore.selectedIDs
    }

    func toggleCalendar(_ calendar: ProviderCalendar) {
        calendarStore.toggle(calendar.id)
        selectedCalendarIDs = calendarStore.selectedIDs
    }

    func isCalendarSelected(_ calendar: ProviderCalendar) -> Bool {
        selectedCalendarIDs.contains(calendar.id)
    }
}
