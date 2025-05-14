//
//  DefaultViews.swift
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

public struct DefaultDayEventView: View {
    public var event: CalendarEvent

    public init(_ event: CalendarEvent) {
        self.event = event
    }

    public var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle.styled(8, .gray.opacity(0.3))
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
