//
//  Untitled.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 17.04.2025.
//

import SwiftUI

struct WeekDaysSwitcher<WeekSwitcherDay: View>: View {
    @Binding var selectedDate: Date
    @State var anchorDate: Date
    var calendarDisplayMode: CalendarDisplayMode
    @ViewBuilder var weekSwitcherDayBuilder: (Date, Bool, Bool) -> WeekSwitcherDay

    private var calendar: Calendar { Calendar.current }

    var body: some View {
        switch calendarDisplayMode {
        case .day:
            fullWeekView
        case .threeDays:
            threeDayWeekView
        case .month:
            weekdaysOnlyView
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
                weekSwitcherDayBuilder(day, isSelected, isToday)
            }
        }
    }
}

public struct DefaultWeekSwitcherDayView: View {
    var day: Date
    var isSelected: Bool
    var isToday: Bool

    public init(day: Date, isSelected: Bool, isToday: Bool) {
        self.day = day
        self.isSelected = isSelected
        self.isToday = isToday
    }

    public var body: some View {
        VStack {
            Text(day.formatted("EEE"))
            Text(day.formatted("d"))
        }
        .padding(8)
        .background(isSelected ? Color.accentColor :
                        isToday ? Color.clear :
                        Color.clear)
        .foregroundColor(isSelected ? .white :
                            isToday ? .accentColor :
                .primary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
