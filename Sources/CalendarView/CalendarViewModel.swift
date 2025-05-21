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
        var result = [CalendarEvent]()
        for eventProvider in eventProviders {
            if let providerResult = try? await eventProvider.getEvents(from: interval.start, to: interval.end, selectedCalendarIDs: selectedCalendarIDs) {
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
        selectedCalendarIDs = calendarStore.selectedIDs
    }

    func toggleCalendar(_ calendar: ProviderCalendar) {
        calendarStore.toggle(calendar.id)
        selectedCalendarIDs = calendarStore.selectedIDs
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

