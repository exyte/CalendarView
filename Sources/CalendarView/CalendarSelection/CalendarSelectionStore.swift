//
//  CalendarSelectionStore.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.05.2025.
//

import Foundation

final class CalendarSelectionStore {
    private let key = "deselectedCalendarIDs"

    var deselectedIDs: Set<String> {
        get {
            let ids = UserDefaults.standard.array(forKey: key) as? [String] ?? []
            return Set(ids)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }

    func toggle(_ id: String) {
        var ids = deselectedIDs
        if deselectedIDs.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        deselectedIDs = ids
    }

    func getSelectedIDs(calendars: [ProviderCalendar]) -> [String] {
        calendars.map { $0.id }.filter { !deselectedIDs.contains($0) }
    }
}
