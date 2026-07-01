//
//  DefaultWeekSwitcherDayView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 19.06.2025.
//

import SwiftUI

public struct DefaultDayInWeekView: View {
    @Environment(\.calendarTheme) var theme

    var params: WeekSwitcherDayBuilderParams

    static let today = Date().startOfDay

    public init(params: WeekSwitcherDayBuilderParams) {
        self.params = params
    }

    public var body: some View {
        let isSelected = params.fullscreenDate == params.day
        let isToday = Self.today == params.day
        let isWeekend = params.day.isWeekend

        let textColor =
        isSelected && isToday ? theme.week.todaySelectedText :
        isSelected ? theme.week.selectedText :
        isToday ? theme.week.todayText :
        isWeekend ? theme.week.weekendText :
        theme.week.text

        let bgColor =
        isSelected && isToday ? theme.week.todaySelectedBackground :
        isSelected ? theme.week.selectedBackground :
        isToday ? theme.week.todayBackground :
        theme.week.background

        let weekdayLabel = Text(params.day.formatted("EEE"))
            .libraryFont(15, isWeekend ? theme.week.weekendText : theme.week.text)
            .lineLimit(1)

        VStack(spacing: 10) {
            if params.monthDisplayMode {
                Spacer()
                weekdayLabel
                    .padding(.bottom, 10)
            } else {
                weekdayLabel

                Text(params.day.formatted("d"))
                    .libraryFont(17, .semibold, textColor)
                    .lineLimit(1)
                    .padding(12)
                    .background(Circle().foregroundStyle(bgColor))
            }
        }
    }
}
