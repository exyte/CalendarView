//
//  ContentView.swift
//  CalendarViewExample
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI
import CalendarView

struct ContentView: View {

    var body: some View {
        CalendarView()
            .headerBackground(.color(.green.opacity(0.5)))
//            .calendarTheme(.init(
//                main: .init(text: .green, accent: .red, background: .yellow.opacity(0.1)),
//                header: .init(text: .purple),
//                week: .init(text: .gray, todayText: .green, selectedText: .yellow, todaySelectedText: .purple, background: .blue.opacity(0.1), todayBackground: .pink.opacity(0.1), selectedBackground: .cyan, todaySelectedBackground: .brown),
//                day: .init(hourText: .purple, eventText: .cyan, background: .pink.opacity(0.1), separators: .brown),
//                month: .init(dateText: .purple, eventText: .cyan, background: .pink.opacity(0.1), separators: .brown),
//                year: .init(dateText: .purple, monthText: .teal, todayText: .pink, background: .brown.opacity(0.2))
//            ))
    }
}

public struct DefaultDayEventView: View {
    public var event: CalendarEvent

    public init(_ event: CalendarEvent) {
        self.event = event
    }

    public var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle.styled(8, event.calendarColor.opacity(0.3))
                .layoutPriority(1)

            ViewThatFits {
                VStack(alignment: .leading, spacing: 2) {
                    titleView()
                    timeView()
                    priorityView()
                }
                VStack(alignment: .leading, spacing: 2) {
                    titleView()
                    timeView()
                }
                titleView()
                    .frame(maxHeight: .infinity)
            }
            .padding(4, 2)
        }
    }

    func titleView() -> some View {
        Text(event.title)
            .font(.system(size: 16))
    }

    func timeView() -> some View {
        HStack(spacing: 3) {
            Image(systemName: "clock")
            Text(event.startDate.formatted("H:mm"))
            Text("-")
            Text(event.endDate.formatted("H:mm"))
        }
        .font(.system(size: 13))
        .roundedRectangleBackground(4, 0, cornerRadius: 4, .green.opacity(0.3))
    }

    func priorityView() -> some View {
        HStack {
            Text(event.priority.rawValue)
        }
        .font(.system(size: 13))
        .roundedRectangleBackground(4, 0, cornerRadius: 4, .yellow.opacity(0.3))
    }
}
