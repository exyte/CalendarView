//
//  CalendarSelectionStore.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.05.2025.
//

import Foundation

final class FilterCalendarsStore {
    private let key = "deselectedCalendarIDs"
    private let defaults = UserDefaults.standard

    var deselectedIDs: Set<String> {
        get {
            let ids = defaults.array(forKey: key) as? [String] ?? []
            return Set(ids)
        }
        set {
            defaults.set(Array(newValue), forKey: key)
        }
    }

    func toggle(_ id: String) {
        var ids = deselectedIDs
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        deselectedIDs = ids
    }

    func getSelectedIDs(calendars: [ProviderCalendar]) -> [String] {
        let deselected = deselectedIDs // store to avoid extra UserDefaults calls
        return calendars.map(\.id).filter { !deselected.contains($0) }
    }
}
