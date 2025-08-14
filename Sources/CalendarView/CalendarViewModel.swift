//
//  CalendarViewModel.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

import Foundation

@MainActor
class CalendarViewModel: ObservableObject {
    @Published public var events: [CalendarEvent] = []
    @Published public var reminders: [CalendarReminder] = []
    @Published public var calendars: [ProviderCalendar] = []
    @Published public var deselectedCalendarIDs: [String] = []

    private var eventProviders: [CalendarsProvider] = []
    private var calendarSelectionStore = CalendarSelectionStore()

    init(providers: [CalendarsProvider]) {
        if providers.isEmpty {
            eventProviders.append(AppleCalendarsProvider())
            eventProviders.append(LocalCalendarsProvider())
        } else {
            eventProviders.append(contentsOf: providers)
        }
    }
    
    func fetch(_ interval: DateInterval) async {
        await fetchCalendars()
        let selectedIDs = calendarSelectionStore.getSelectedIDs(calendars: calendars)
        if selectedIDs.isEmpty {
            // user explicitly deselected all of his calendards
            events = []
            reminders = []
            return
        }

        var resultE = [CalendarEvent]()
        for eventProvider in eventProviders {
            if let providerResult = try? await eventProvider.getEvents(from: interval.start, to: interval.end, selectedCalendarIDs: selectedIDs) {
                resultE.append(contentsOf: providerResult)
            }
        }
        events = resultE

        var resultR = [CalendarReminder]()
        for eventProvider in eventProviders {
            if let providerResult = try? await eventProvider.getReminders(from: interval.start, to: interval.end, selectedCalendarIDs: selectedIDs) {
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
        deselectedCalendarIDs = Array(calendarSelectionStore.deselectedIDs)
    }

    func toggleCalendar(_ calendar: ProviderCalendar) {
        calendarSelectionStore.toggle(calendar.id)
        deselectedCalendarIDs = Array(calendarSelectionStore.deselectedIDs)
    }

    func isCalendarSelected(_ calendar: ProviderCalendar) -> Bool {
        !deselectedCalendarIDs.contains(calendar.id)
    }

    func resetCache() {
        events = []
        reminders = []
    }

    // MARK: - adding

    func getProvider() -> EditableCalendarsProvider? {
        eventProviders.first(where: { $0 is EditableCalendarsProvider }) as? EditableCalendarsProvider
    }

    func addCalendar(_ calendar: ProviderCalendar) async {
        if let provider = getProvider() {
            do {
                try await provider.addCalendar(calendar)
                await fetchCalendars()
            } catch {
                print(error)
            }
        }
    }

    func addEvent(_ event: CalendarEvent) async {
        if let provider = getProvider() {
            do {
                try await provider.addEvent(event)
            } catch {
                print(error)
            }
        }
    }

    func addReminder(_ reminder: CalendarReminder) async {
        if let provider = getProvider() {
            do {
                try await provider.addReminder(reminder)
            } catch {
                print(error)
            }
        }
    }


    func updateEvent(_ event: CalendarEvent, oldStartDate: Date) async {
        if let provider = getProvider() {
            do {
                try await provider.updateEvent(event, oldStartDate: oldStartDate)
            } catch {
                print(error)
            }
        }
    }

    func updateReminder(_ reminder: CalendarReminder, oldStartDate: Date) async {
        if let provider = getProvider() {
            do {
                try await provider.updateReminder(reminder, oldStartDate: oldStartDate)
            } catch {
                print(error)
            }
        }
    }
}
