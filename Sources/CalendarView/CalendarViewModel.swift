//
//  CalendarViewModel.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 22.04.2025.
//

import SwiftUI

@MainActor
class CalendarViewModel: ObservableObject {
    @Published public var events: [CalendarEvent] = []

    private var eventProviders: [CalendarEventProvider] = [AppleEventProvider(), LocalEventsProvider()]

    func fetch(_ interval: DateInterval) async {
        var result = [CalendarEvent]()
        for eventProvider in eventProviders {
            print(interval)
            if let providerResult = try? await eventProvider.getEvents(from: interval.start, to: interval.end) {
                result.append(contentsOf: providerResult)
            }
        }
        for r in result {
           // print(r.toString())
        }
        events = result
    }
}
