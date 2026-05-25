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
    private let preloadSize: Int = 4

    init(providers: [CalendarsProvider]) {
        eventProviders = providers
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

        events = await fetchEvents(interval, selectedIDs: selectedIDs)
        reminders = await fetchReminders(interval, selectedIDs: selectedIDs)
    }
    
    private func fetchEvents(_ interval: DateInterval, selectedIDs: [String]) async -> [CalendarEvent] {
        var resultE = [CalendarEvent]()
        for eventProvider in eventProviders {
            let start = interval.start.adding(.day, value: -preloadSize)
            let end = interval.end.adding(.day, value: preloadSize)
            if let providerResult = try? await eventProvider.getEvents(from: start, to: end, selectedCalendarIDs: selectedIDs) {
                resultE.append(contentsOf: providerResult)
            }
        }
        return resultE
    }
    
    private func fetchReminders(_ interval: DateInterval, selectedIDs: [String]) async -> [CalendarReminder] {
        var resultR = [CalendarReminder]()
        for eventProvider in eventProviders {
            let start = interval.start.adding(.day, value: -preloadSize)
            let end = interval.end.adding(.day, value: preloadSize)
            if let providerResult = try? await eventProvider.getReminders(from: start, to: end, selectedCalendarIDs: selectedIDs) {
                resultR.append(contentsOf: providerResult)
            }
        }
        return resultR
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

    func deleteEvent(_ event: CalendarEvent) async {
        if let provider = getProvider() {
            do {
                try await provider.deleteEvent(event)
            } catch {
                print(error)
            }
        }
    }

    func deleteReminder(_ reminder: CalendarReminder) async {
        if let provider = getProvider() {
            do {
                try await provider.deleteReminder(reminder)
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
    
    func getEventsAndRemindersCount(from date: Date, displayMode: CalendarDisplayMode, fullscreenDate: Date) -> Int {
        var count = 0
        
        count += getEvents(from: date, displayMode: displayMode, fullscreenDate: fullscreenDate).count
        count += getReminders(from: date, displayMode: displayMode, fullscreenDate: fullscreenDate).count

        return count
    }
    
    func getEvents(from date: Date, displayMode: CalendarDisplayMode, fullscreenDate: Date) -> [CalendarEvent] {
        let interval = displayMode.interval(date)
        let startDate = interval.start
        let endDate = interval.end
        var events = self.events
            .filter { !$0.isAllDay }
            .filter { $0.repeatType == .never }
            .filter { $0.startDate >= startDate && $0.startDate <= endDate }

        for i in 0..<displayMode.rawValue {
            let currentDate = date.adding(.day, value: i)
            let interval = CalendarDisplayMode.day.interval(currentDate)
            let startDate = interval.start
            let allDayEvents = self.events
                .filter { $0.isAllDay }
                .filter { $0.repeatType == .never }
                .filter { $0.startDate <= startDate && $0.endDate >= startDate }

            events.append(contentsOf: allDayEvents)
        }
        
        let repeatEvents = self.events
            .filter { $0.repeatType != .never }
            .filter { $0.repeatableEventOccursOn(date: fullscreenDate) }

        events.append(contentsOf: repeatEvents)
        
        return events
    }
    
    func getReminders(from date: Date, displayMode: CalendarDisplayMode, fullscreenDate: Date) -> [CalendarReminder] {
        let interval = displayMode.interval(date)
        let startDate = interval.start
        let endDate = interval.end
        var reminders = self.reminders
            .filter { $0.repeatType == .never }
            .filter { $0.startDate >= startDate && $0.startDate <= endDate }
        
        let repeatReminders = self.reminders
            .filter { $0.repeatType != .never }
            .filter { $0.repeatableEventOccursOn(date: fullscreenDate) }

        reminders.append(contentsOf: repeatReminders)
        
        return reminders
    }
}
