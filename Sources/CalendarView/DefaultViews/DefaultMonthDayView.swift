//
//  DefaultMonthDayView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 23.04.2025.
//

import SwiftUI

public struct DefaultMonthDayView: View {
    public var date: Date
    public var events: [CalendarEvent]

    public init(date: Date, events: [CalendarEvent]) {
        self.date = date
        self.events = events
    }

    let maxEvents = 3

    public var body: some View {
        VStack {
            Color("appLightGrey", bundle: .module).frame(height: 1)
                .padding(.vertical, 10)

            Text(date.formatted("d"))
                .foregroundStyle(Color("appBlack", bundle: .module))

            if events.count <= maxEvents {
                ForEach(events) { event in
                    DefaultMonthEventView(event: event)
                }
            } else {
                ForEach(0..<maxEvents-1, id: \.self) {
                    DefaultMonthEventView(event: events[$0])
                }
                Text("+\(events.count - maxEvents - 1)")
            }
            Spacer()
        }
    }
}

public struct DefaultMonthEventView: View {
    public var event: CalendarEvent

    public var body: some View {
        VStack {
            Text(event.title)
                .lineLimit(1)
                .background(Color.green.opacity(0.3).cornerRadius(2))
        }
    }
}
