//
//  CalendarSelectionStore.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.05.2025.
//

import Foundation

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
