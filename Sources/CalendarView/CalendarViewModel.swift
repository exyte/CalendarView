//
//  CalendarViewModel.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

import Foundation

@Observable
@MainActor
class CalendarViewModel {
    private(set) var events: [CalendarEvent] = []
    private(set) var reminders: [CalendarReminder] = []
    private(set) var calendars: [ProviderCalendar] = []
    private(set) var deselectedCalendarIDs: [String] = []

    private var eventProviders: [CalendarsProvider] = []
    private var calendarSelectionStore = FilterCalendarsStore()
    private let preloadSize: Int = 4
    private var currentFetchTask: Task<Void, Never>?

    init(providers: [CalendarsProvider]) {
        eventProviders = providers
    }

    // MARK: - calendars

    func fetchCalendars() async {
        var result: [ProviderCalendar] = []
        for provider in eventProviders {
            if let providerCalendars = try? await provider.getCalendars() {
                result.append(contentsOf: providerCalendars)
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

    // MARK: - entities fetching

    func fetch(_ interval: DateInterval) async {
        currentFetchTask?.cancel()
        let task = Task { @MainActor in
            await performFetch(interval)
        }
        currentFetchTask = task
        await task.value
    }

    private func performFetch(_ interval: DateInterval) async {
        await fetchCalendars()
        if Task.isCancelled { return }

        let selectedIDs = calendarSelectionStore.getSelectedIDs(calendars: calendars)
        if selectedIDs.isEmpty {
            events = []
            reminders = []
            return
        }

        let start = interval.start.adding(.day, value: -preloadSize)
        let end = interval.end.adding(.day, value: preloadSize)

        var fetchedEvents: [CalendarEvent] = []
        var fetchedReminders: [CalendarReminder] = []
        for provider in eventProviders {
            if let providerEvents = try? await provider.getEvents(from: start, to: end, selectedCalendarIDs: selectedIDs) {
                fetchedEvents.append(contentsOf: providerEvents)
            }
            if let providerReminders = try? await provider.getReminders(from: start, to: end, selectedCalendarIDs: selectedIDs) {
                fetchedReminders.append(contentsOf: providerReminders)
            }
        }

        if Task.isCancelled { return }
        events = fetchedEvents
        reminders = fetchedReminders
    }

    func getEventsAndRemindersCount(from date: Date, displayMode: CalendarDisplayMode, fullscreenDate: Date) -> Int {
        getEvents(from: date, displayMode: displayMode, fullscreenDate: fullscreenDate).count
        + getReminders(from: date, displayMode: displayMode, fullscreenDate: fullscreenDate).count
    }

    func getEvents(from date: Date, displayMode: CalendarDisplayMode, fullscreenDate: Date) -> [CalendarEvent] {
        let interval = displayMode.interval(date)
        let startDate = interval.start
        let endDate = interval.end

        var result: [CalendarEvent] = []
        result.reserveCapacity(events.count)

        let visibleDayStarts: [Date] = (0..<displayMode.rawValue).map {
            date.adding(.day, value: $0).startOfDay
        }

        for event in events {
            switch event.repeatType {
            case .never:
                if event.isAllDay {
                    if visibleDayStarts.contains(where: { event.startDate <= $0 && event.endDate >= $0 }) {
                        result.append(event)
                    }
                } else if event.startDate >= startDate && event.startDate <= endDate {
                    result.append(event)
                }
            default:
                if event.repeatableEventOccursOn(date: fullscreenDate) {
                    result.append(event)
                }
            }
        }
        return result
    }

    func getReminders(from date: Date, displayMode: CalendarDisplayMode, fullscreenDate: Date) -> [CalendarReminder] {
        let interval = displayMode.interval(date)
        let startDate = interval.start
        let endDate = interval.end

        var result: [CalendarReminder] = []
        result.reserveCapacity(reminders.count)

        for reminder in reminders {
            if reminder.repeatType == .never {
                if reminder.startDate >= startDate && reminder.startDate <= endDate {
                    result.append(reminder)
                }
            } else if reminder.repeatableEventOccursOn(date: fullscreenDate) {
                result.append(reminder)
            }
        }
        return result
    }

    func resetCache() {
        events = []
        reminders = []
    }

    // MARK: - editing

    func getProvider() -> EditableCalendarsProvider? {
        eventProviders.first(where: { $0 is EditableCalendarsProvider }) as? EditableCalendarsProvider
    }

    private func withProvider(_ op: (EditableCalendarsProvider) async throws -> Void) async {
        guard let provider = getProvider() else { return }
        do {
            try await op(provider)
        } catch {
            print(error)
        }
    }

    func addCalendar(_ calendar: ProviderCalendar) async {
        await withProvider { provider in
            try await provider.addCalendar(calendar)
            await self.fetchCalendars()
        }
    }

    func add<E: CalendarEntity>(_ entity: E) async {
        await withProvider { provider in
            switch entity {
            case let event as CalendarEvent:
                try await provider.addEvent(event)
            case let reminder as CalendarReminder:
                try await provider.addReminder(reminder)
            default:
                assertionFailure("Unsupported CalendarEntity type: \(type(of: entity))")
            }
        }
    }

    func delete<E: CalendarEntity>(_ entity: E) async {
        await withProvider { provider in
            switch entity {
            case let event as CalendarEvent:
                try await provider.deleteEvent(event)
            case let reminder as CalendarReminder:
                try await provider.deleteReminder(reminder)
            default:
                assertionFailure("Unsupported CalendarEntity type: \(type(of: entity))")
            }
        }
    }

    func update<E: CalendarEntity>(_ entity: E, oldStartDate: Date) async {
        await withProvider { provider in
            switch entity {
            case let event as CalendarEvent:
                try await provider.updateEvent(event, oldStartDate: oldStartDate)
            case let reminder as CalendarReminder:
                try await provider.updateReminder(reminder, oldStartDate: oldStartDate)
            default:
                assertionFailure("Unsupported CalendarEntity type: \(type(of: entity))")
            }
        }
    }
}
