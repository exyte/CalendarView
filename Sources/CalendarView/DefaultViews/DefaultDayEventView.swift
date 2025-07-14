//
//  DefaultDayEventView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.05.2025.
//

import SwiftUI

public struct DefaultDayEventView: View {
    @Environment(\.calendarTheme) private var theme

    public var entity: any CalendarEntity

    public init(entity: any CalendarEntity) {
        self.entity = entity
    }

    var isEvent: Bool {
        entity as? CalendarEvent != nil
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
                let color = isEvent ? entity.calendarColor.blended(opacity: 0.3) : Color.named("appLightGrey")
                RoundedRectangle.styled(8, color)
                    .layoutPriority(1)

                HStack(alignment: .top) {
                    if let reminder = entity as? CalendarReminder {
                        checkmarkView(reminder)
                            .padding(.horizontal, 6)
                    }

                    if isEvent {
                        entity.calendarColor
                            .frame(width: 2)
                            .cornerRadius(6)
                    }

                    Text(entity.title)
                        .systemFont(13, .semibold, theme.day.eventText)

                    Spacer()
                }
                .padding(4, 12)
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
                RoundedRectangle(cornerRadius: 4).styled(.clear, border: Color.named("appGrey"), 1)
                    .size(20)
            }
        }
    }
}
