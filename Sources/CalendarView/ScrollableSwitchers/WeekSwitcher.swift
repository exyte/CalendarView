//
//  Untitled.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI

struct WeekDaysSwitcher<WeekSwitcherDay: View>: View {
    @Environment(\.calendarTheme) private var theme

    @Binding var selectedDate: Date
    var calendarDisplayMode: CalendarDisplayMode
    @ViewBuilder var weekSwitcherDayBuilder: (WeekSwitcherDayBuilderParams) -> WeekSwitcherDay

    @State private var anchorDate: Date = Date()
    private var calendar: Calendar { Calendar.current }

    var body: some View {
        ZStack {
            switch calendarDisplayMode {
            case .day:
                fullWeekView
            case .threeDays:
                threeDayWeekView
            case .month:
                weekdaysOnlyView
            }
        }
        .onChange(of: selectedDate) {
            anchorDate = selectedDate
        }
    }

    @ViewBuilder
    var fullWeekView: some View {
        let startOfWeek = anchorDate.startOfWeek

        HStack(spacing: 8) {
            Button {
                anchorDate = anchorDate.adding(.day, value: -7)
            } label: {
                Image(systemName: "arrow.left")
            }

            daysView(startDay: startOfWeek, length: 7)

            Button {
                anchorDate = anchorDate.adding(.day, value: 7)
            } label: {
                Image(systemName: "arrow.right")
            }
        }
    }

    var threeDayWeekView: some View {
        HStack(spacing: 8) {
            Button {
                anchorDate = anchorDate.adding(.day, value: -1)
            } label: {
                Image(systemName: "arrow.left")
            }

            daysView(startDay: anchorDate, length: 3)

            Button {
                anchorDate = anchorDate.adding(.day, value: 1)
            } label: {
                Image(systemName: "arrow.right")
            }
        }
    }

    @ViewBuilder
    var weekdaysOnlyView: some View {
        let startOfWeek = anchorDate.startOfWeek
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { i in
                let day = startOfWeek.adding(.day, value: i)
                Text(day.formatted("EEE"))
                    .systemFont(15, theme.week.text)
                    .greedyWidth()
            }
        }
    }

    private func daysView(startDay: Date, length: Int) -> some View {
        ForEach(0..<length, id: \.self) { i in
            let day = startDay.adding(.day, value: i)
            let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
            let isToday = calendar.isDateInToday(day)
            Button {
                withAnimation {
                    selectedDate = day
                }
            } label: {
                weekSwitcherDayBuilder(WeekSwitcherDayBuilderParams(day: day, isSelected: isSelected, isToday: isToday))
            }
        }
        .greedyWidth()
    }
}

public struct DefaultWeekSwitcherDayView: View {
    @Environment(\.calendarTheme) private var theme

    var day: Date
    var isSelected: Bool
    var isToday: Bool

    public init(day: Date, isSelected: Bool, isToday: Bool) {
        self.day = day
        self.isSelected = isSelected
        self.isToday = isToday
    }

    public var body: some View {
        let textColor =
        isSelected && isToday ? theme.week.todaySelectedText :
        isSelected ? theme.week.selectedText :
        isToday ? theme.week.todayText :
        theme.week.text

        let bgColor =
        isSelected && isToday ? theme.week.todaySelectedBackground :
        isSelected ? theme.week.selectedBackground :
        isToday ? theme.week.todayBackground :
        theme.week.background

        VStack {
            Text(day.formatted("EEE")).font(.system(size: 15))
                .systemFont(15, theme.week.text)
                .lineLimit(1)
            Text(day.formatted("d")).font(.system(size: 17, weight: .semibold))
                .systemFont(17, .semibold, textColor)
        }
        .padding(4, 8)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
