//
//  DayLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

public struct DayLayout<Content: View>: View {
    @Environment(\.calendarTheme) private var theme
    
    @Binding var selectedDate: Date
    var daysCount: Int
    var events: [CalendarEvent]
    var updateID: UUID
    var customizationParams: CalendarViewCustomizationParams
    @ViewBuilder var dayEventBuilder: (CalendarEvent)->Content

    init(selectedDate: Binding<Date>, daysCount: Int, events: [CalendarEvent], updateID: UUID, customizationParams: CalendarViewCustomizationParams, dayEventBuilder: @escaping (CalendarEvent) -> Content) {
        self._selectedDate = selectedDate
        self.daysCount = daysCount
        self.events = events
        self.updateID = updateID
        self.customizationParams = customizationParams
        self.dayEventBuilder = dayEventBuilder

        let isAllDayGrouped = Dictionary(grouping: events, by: \.isAllDay)
        self.allDayEvents = isAllDayGrouped[true] ?? []
        let nonAllDayEvents = isAllDayGrouped[false] ?? []
        self.eventsByDay = daysCount == 1 ? [selectedDate.wrappedValue: nonAllDayEvents] : nonAllDayEvents.groupedByDay()
    }

    @State private var hourTextSize: CGSize = .zero

    var firstOccupiedHour: Int {
        events.map { $0.startDate.getHour() } .min { $0 < $1 } ?? 0
    }

    var allDayEvents: [CalendarEvent]
    var eventsByDay: [Date: [CalendarEvent]] = [:]

    public var body: some View {
        VStack {
            // all day events
            if !allDayEvents.isEmpty {
                HStack {
                    Text("all-day")
                        .systemFont(13, theme.day.hourText)
                    ForEach(allDayEvents) { event in
                        dayEventBuilder(event)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 9)
            }

            // events by hour
            GeometryReader { global in
                ScrollViewReader { proxy in
                    ScrollView {
                        HStack {
                            let oneHourHeight = global.size.height / CGFloat(customizationParams.hoursToFit)

                            hourLabels(oneHourHeight)

                            ZStack(alignment: .top) {
                                separatorsView(oneHourHeight)
                                nowLine(oneHourHeight)
                                dayEventsView
                            }
                            .padding(.top, hourTextSize.height)
                        }
                    }
                    .onChange(of: updateID) {
                        proxy.scrollTo(firstOccupiedHour, anchor: .top)
                    }
                }
            }
        }
    }

    func hourLabels(_ oneHourHeight: CGFloat) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(0..<25, id: \.self) { i in
                Text("\(i):00")
                    .systemFont(13, theme.day.hourText)
                    .sizeGetter($hourTextSize)
                    .frame(height: oneHourHeight, alignment: .top)
                    .id(i)
                    .padding(.leading, 9)
            }
        }
    }

    func separatorsView(_ oneHourHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<25, id: \.self) { i in
                VStack(spacing: 0) {
                    theme.day.separators.frame(height: 1)
                    Spacer()
                }
                .frame(height: oneHourHeight, alignment: .top)
            }
        }
    }

    func nowLine(_ oneHourHeight: CGFloat) -> some View {
        theme.day.todayLine.frame(height: 2)
            .overlay(alignment: .leading) {
                theme.day.todayLine.frame(width: 2, height: 12)
                    .padding(.leading, 1)
            }
            .offset(y: oneHourHeight * startCoeff(Date()))
    }

    var dayEventsView: some View {
        HStack {
            ForEach(0..<daysCount, id: \.self) { i in
                theme.day.separators.frame(width: 1)
                GeometryReader { g in
                    let date = selectedDate.adding(.day, value: i)
                    DayEventsLayout(events: eventsByDay[date] ?? [], size: g.size, horSpacing: customizationParams.horSpacing, verSpacing: customizationParams.verSpacing, dayEventBuilder: dayEventBuilder)
                }
                .padding(.trailing, 9)
            }
        }
    }

    func startCoeff(_ date: Date) -> CGFloat {
        CGFloat((date.getHour() * 60 + date.getMinute())) / CGFloat(60)
    }
}

extension Sequence where Element == CalendarEvent {
    func groupedByDay() -> [Date: [CalendarEvent]] {
        Dictionary(grouping: self) {
            $0.startDate.startOfDay
        }
    }
}
