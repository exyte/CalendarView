//
//  DefaultMonthDayView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 23.04.2025.
//

import SwiftUI

public struct DefaultDayInMonthView: View {
    @Environment(\.calendarTheme) private var theme

    var params: MonthDayBuilderParams

    @State var monthEventSize: CGSize?

    static let today = Date().startOfDay

    public init(params: MonthDayBuilderParams) {
        self.params = params
    }

    public var body: some View {
        VStack(spacing: 6) {
            theme.month.separators.frame(height: 1)
                .padding(.bottom, 10)

            let isToday = params.date.startOfDay == Self.today
            Text("\(params.date.getDay())")
                .systemFont(17, .semibold, isToday ? theme.month.todayText : theme.month.dateText)
                .applyIf(isToday) {
                    $0.padding(4)
                        .background(theme.month.todayBackground)
                        .clipShape(Circle())
                        .padding(.vertical, -4)
                }

            GeometryReader { g in
                if let monthEventSize {
                    eventsWithEllipsis(events: params.events, parentHeight: g.size.height, childHeight: monthEventSize.height)
                }

                Spacer()
            }
        }
        .background {
            MeasuringTrickView(size: $monthEventSize) {
                DefaultMonthEventView(entity: CalendarEvent(title: "a", startDate: Date()))
            }
        }
    }

    @ViewBuilder
    func eventsWithEllipsis(events: [any CalendarEntity], parentHeight: CGFloat, childHeight: CGFloat) -> some View {
        let padding = 6.0
        let maxEvents = Int(parentHeight / (childHeight + padding))
        VStack(spacing: padding) {
            if events.count <= maxEvents {
                ForEach(0..<events.count, id: \.self) {
                    DefaultMonthEventView(entity: events[$0])
                }
            } else {
                ForEach(0..<maxEvents-1, id: \.self) {
                    DefaultMonthEventView(entity: events[$0])
                }
                Text("+\(events.count - (maxEvents - 1))")
                    .systemFont(11, theme.month.plusMoreEventsText)
            }
        }
        .padding(.horizontal, 1)
    }
}

public struct DefaultMonthEventView: View {
    @Environment(\.calendarTheme) private var theme

    public var entity: any CalendarEntity

    public var body: some View {
        VStack {
            HStack(spacing: 0) {
                if let reminder = entity as? CalendarReminder {
                    checkmarkView(reminder)
                        .padding(.horizontal, 2)
                }

                Text(entity.title)
                    .systemFont(11, .semibold, theme.month.eventText)
                    .lineLimit(1)
                    .padding(2, 1)

                Spacer()
            }
            .background(entity.calendarColor.opacity(0.3).cornerRadius(4))
        }
    }

    func checkmarkView(_ reminder: CalendarReminder) -> some View {
        ZStack {
            if reminder.isCompleted {
                RoundedRectangle.styled(2, entity.calendarColor)
                    .size(10)

                Image(.checkmark)
                    .resizable()
                    .size(6)
            } else {
                RoundedRectangle(cornerRadius: 4).styled(.clear, border: Color.named("appGrey"), 1)
                    .size(10)
            }
        }
    }
}
