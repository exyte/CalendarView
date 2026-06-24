//
//  DefaultDayEventView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

public struct DefaultDayEventView: View {
    @Environment(\.calendarTheme) var theme

    public var entity: any CalendarEntity

    var isEvent: Bool {
        entity as? CalendarEvent != nil
    }

    public init(entity: any CalendarEntity) {
        self.entity = entity
    }

    public var body: some View {
        if let event = entity as? CalendarEvent, event.isAllDay {
            ZStack(alignment: .leading) {
                RoundedRectangle.styled(8, event.calendarColor.opacity(0.3))

                Text(event.title)
                    .systemFont(13, .semibold, theme.day.eventText)
                    .padding(8, 4)
            }
        } else {
            ZStack(alignment: .top) {
                let color = isEvent ? entity.calendarColor.blended(opacity: 0.3) : theme.main.background
                
                RoundedRectangle.styled(8, color)
                    .layoutPriority(1)

                HStack {
                    if let reminder = entity as? CalendarReminder {
                        checkmarkView(reminder)
                            .padding(.horizontal, 6)
                    }

                    if isEvent {
                        entity.calendarColor
                            .frame(width: 2)
                            .cornerRadius(6)
                            .padding(.vertical, 8)
                    }

                    Text(entity.title)
                        .systemFont(13, .semibold, theme.day.eventText)

                    Spacer()
                }
                .padding(.horizontal,  4)
            }
        }
    }

    func checkmarkView(_ reminder: CalendarReminder) -> some View {
        ZStack {
            if reminder.isCompleted {
                RoundedRectangle.styled(4, entity.calendarColor)
                    .size(20)

                Image(.checkmark)
                    .size(10)
            } else {
                RoundedRectangle(cornerRadius: 4).styled(.clear, border: Color(.appGrey2), 1)
                    .size(20)
            }
        }
    }
}
