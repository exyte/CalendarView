//
//  DefaultDayEventView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

public struct DefaultDayEventView: View {
    @Environment(\.calendarTheme) private var theme

    public var event: CalendarEvent

    public init(_ event: CalendarEvent) {
        self.event = event
    }

    public var body: some View {
        if event.isAllDay {
            ZStack(alignment: .leading) {
                RoundedRectangle.styled(8, event.calendarColor.opacity(0.3))

                Text(event.title)
                    .systemFont(13, .semibold, theme.day.eventText)
                    .padding(8, 4)
            }
        } else {
            ZStack(alignment: .top) {
                let color = event.calendarColor.blended(opacity: 0.3)
                RoundedRectangle.styled(8, color)
                    .layoutPriority(1)

                HStack(alignment: .top) {
                    if !event.isLocal {
                        event.calendarColor
                            .frame(width: 2)
                            .cornerRadius(6)
                    }
                    Text(event.title)
                        .systemFont(13, .semibold, theme.day.eventText)
                    Spacer()
                }
                .padding(4, 12)
            }
        }
    }
}
