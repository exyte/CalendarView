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
    public var calendars: [ProviderCalendar] = []
    public var selectedCalendarIDs: Set<String> = []

    private let eventProviders: [CalendarEventProvider] = [AppleEventProvider(), LocalEventsProvider()]
    private var calendarStore = CalendarSelectionStore()

    func fetch(_ interval: DateInterval) async {
        // user explicitly deselected all of his calendards
        if calendarStore.selectedIDsExists && calendarStore.selectedIDs.isEmpty {
            events = []
            return
        }

        var result = [CalendarEvent]()
        for eventProvider in eventProviders {
            if let providerResult = try? await eventProvider.getEvents(from: interval.start, to: interval.end, selectedCalendarIDs: calendarStore.selectedIDs) {
                result.append(contentsOf: providerResult)
            }
        }
        events = result
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

final class CalendarSelectionStore {
    private let key = "SelectedCalendarIDs"

    var selectedIDs: Set<String> {
        get {
            let ids = UserDefaults.standard.array(forKey: key) as? [String] ?? []
            return Set(ids)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }

    var selectedIDsExists: Bool {
        UserDefaults.standard.array(forKey: key) != nil
    }

    func initializeIfNeeded(with calendarIDs: [String]) {
        guard !selectedIDsExists else { return }
        selectedIDs = Set(calendarIDs)
    }

    func toggle(_ id: String) {
        var ids = selectedIDs
        if selectedIDs.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        selectedIDs = ids
    }
}
