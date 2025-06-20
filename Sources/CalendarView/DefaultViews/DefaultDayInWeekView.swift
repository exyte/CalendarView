//
//  DefaultWeekSwitcherDayView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 19.06.2025.
//

import SwiftUI

public struct DefaultDayInWeekView: View {
    @Environment(\.calendarTheme) private var theme

    var params: WeekSwitcherDayBuilderParams

    var isWeekend: Bool { params.day.isWeekend }

    public init(params: WeekSwitcherDayBuilderParams) {
        self.params = params
    }

    public var body: some View {
        let textColor =
        params.isSelected && params.isToday ? theme.week.todaySelectedText :
        params.isSelected ? theme.week.selectedText :
        params.isToday ? theme.week.todayText :
        isWeekend ? theme.week.weekendText :
        theme.week.text

        let bgColor =
        params.isSelected && params.isToday ? theme.week.todaySelectedBackground :
        params.isSelected ? theme.week.selectedBackground :
        params.isToday ? theme.week.todayBackground :
        theme.week.background

        VStack(spacing: 10) {
            Text(params.day.formatted("EEE")).font(.system(size: 15))
                .systemFont(15, isWeekend ? theme.week.weekendText : theme.week.text)
                .lineLimit(1)

            if !params.monthDisplayMode {
                Text(params.day.formatted("d")).font(.system(size: 17, weight: .semibold))
                    .systemFont(17, .semibold, textColor)
                    .lineLimit(1)
                    .padding(8)
                    .background(bgColor)
                    .clipShape(Circle())
            }
        }
    }
}
