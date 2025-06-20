//
//  DefaultMonthDayView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 23.04.2025.
//

import SwiftUI

public struct DefaultMonthDayView: View {
    @Environment(\.calendarTheme) private var theme

    public var date: Date
    public var events: [CalendarEvent]

    public init(date: Date, events: [CalendarEvent]) {
        self.date = date
        self.events = events
    }

    let maxEvents = 3
    let today = Date()

    public var body: some View {
        VStack {
            theme.month.separators.frame(height: 1)
                .padding(.vertical, 10)

            let isToday = date.startOfDay == today.startOfDay
            Text("\(date.getDay())")
                .systemFont(17, .semibold, isToday ? theme.month.todayText : theme.month.dateText)
                .applyIf(isToday) {
                    $0.padding(4)
                        .background(theme.month.todayBackground)
                        .clipShape(Circle())
                        .padding(.top, -4)
                }

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
    @Environment(\.calendarTheme) private var theme

    public var event: CalendarEvent

    public var body: some View {
        VStack {
            Text(event.title)
                .systemFont(11, .semibold, theme.month.eventText)
                .lineLimit(1)
                .background(event.calendarColor.opacity(0.3).cornerRadius(2))
        }
    }
}
