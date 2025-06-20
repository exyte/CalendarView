//
//  MonthLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 24.04.2025.
//

import SwiftUI

public struct MonthLayout<MonthDay: View>: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarCustomizationParams) var customizationParams

    var date: Date
    var events: [CalendarEvent]
    var reminders: [CalendarReminder]
    @ViewBuilder var monthDayBuilder: (MonthDayBuilderParams) -> MonthDay
    var didSelectDay: (Date)->()

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    let today = Date()

    var startOfMonth: Date {
        date.startOfMonth
    }

    // count of empty spaces for days of week before 1st of the month
    var inset: Int {
        let startOfWeek = startOfMonth.startOfWeek(customizationParams.firstDayOfWeek)
        var count = startOfMonth.getWeekday() - startOfWeek.getWeekday()
        if count < 0 {
            count += 7
        }
        return count
    }

    public var body: some View {
        GeometryReader { g in
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0..<inset, id: \.self) { _ in
                    Color.clear
                }

                ForEach(0..<startOfMonth.daysInMonth, id: \.self) { index in
                    let date = startOfMonth.adding(.day, value: index)
                    Button {
                        didSelectDay(date)
                    } label: {
                        monthDayBuilder(MonthDayBuilderParams(date: date, events: eventsFor(date)))
                            .frame(height: g.size.height/6)
                    }
                }
            }
            .frame(height: g.size.height)
        }
    }

    func eventsFor(_ date: Date) -> [CalendarEvent] {
        events.filter { $0.startDate.startOfDay == date }
    }
}
