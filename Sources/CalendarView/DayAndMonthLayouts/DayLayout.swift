//
//  DayLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

public struct DayLayout<Content: View>: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.calendarCustomizationParams) var customizationParams

    @Binding var selectedDate: Date
    @Binding var hoursLabelsInset: CGFloat
    var daysCount: Int
    var events: [CalendarEvent]
    var updateID: UUID
    @ViewBuilder var dayEventBuilder: (CalendarEvent)->Content

    init(selectedDate: Binding<Date>, hoursLabelsInset: Binding<CGFloat>, daysCount: Int, events: [CalendarEvent], updateID: UUID, dayEventBuilder: @escaping (CalendarEvent) -> Content) {
        self._selectedDate = selectedDate
        self._hoursLabelsInset = hoursLabelsInset
        self.daysCount = daysCount
        self.events = events
        self.updateID = updateID
        self.dayEventBuilder = dayEventBuilder

        let isAllDayGrouped = Dictionary(grouping: events, by: \.isAllDay)
        self.allDayEvents = isAllDayGrouped[true] ?? []
        self.allDayEventsByDay = daysCount == 1 ? [selectedDate.wrappedValue: allDayEvents] : allDayEvents.groupedByDay()
        self.nonAllDayEvents = isAllDayGrouped[false] ?? []
        self.nonAllDayEventsByDay = daysCount == 1 ? [selectedDate.wrappedValue: nonAllDayEvents] : nonAllDayEvents.groupedByDay()
    }

    @State private var hourLabelsSize: CGSize = .zero
    @State private var hourTextSize: CGSize = .zero

    var firstOccupiedHour: Int {
        nonAllDayEvents.map { $0.startDate.getHour() } .min { $0 < $1 } ?? 0
    }

    var allDayEvents: [CalendarEvent]
    var allDayEventsByDay: [Date: [CalendarEvent]] = [:]
    var nonAllDayEvents: [CalendarEvent]
    var nonAllDayEventsByDay: [Date: [CalendarEvent]] = [:]

    let horizontalPadding = 8.0

    public var body: some View {
        VStack(spacing: 4) {
            // all day events
            if !allDayEvents.isEmpty {
                allDayEventsView
            }

            // events by hour
            GeometryReader { global in
                ScrollViewReader { proxy in
                    ScrollView {
                        HStack(spacing: 0) {
                            let oneHourHeight = global.size.height / CGFloat(customizationParams.hoursToFit)

                            hourLabels(oneHourHeight)
                                .padding(.horizontal, horizontalPadding)
                                .sizeGetter($hourLabelsSize)

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
        .onChange(of: hourLabelsSize) {
            hoursLabelsInset = hourLabelsSize.width + 2*horizontalPadding
        }
    }

    func hourLabels(_ oneHourHeight: CGFloat) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            ForEach(0..<25, id: \.self) { i in
                Text(Date().setHour(to: i).setMinute(to: 0).formatted(customizationParams.hourLabelFormat))
                    .systemFont(13, theme.day.hourText)
                    .sizeGetter($hourTextSize)
                    .frame(height: oneHourHeight, alignment: .top)
                    .id(i)
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

    @ViewBuilder
    var allDayEventsView: some View {
        let spaceBetweenDays = 2 * customizationParams.horSpacing + 1
        HStack(alignment: .top, spacing: spaceBetweenDays) {
            Color.clear.frame(width: hoursLabelsInset - spaceBetweenDays, height: 1)

            ForEach(0..<daysCount, id: \.self) { i in
                let date = selectedDate.adding(.day, value: i).startOfDay
                VStack {
                    let events = allDayEventsByDay[date] ?? []
                    if events.isEmpty {
                        Color.clear.frame(height: 1)
                    } else {
                        ForEach(events) { event in
                            dayEventBuilder(event)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, customizationParams.horSpacing)
        // can't be a part of layout to be able to align 3-day view correctly
        .overlay(alignment: .topLeading) {
            Text("all-day")
                .systemFont(13, theme.day.hourText)
                .padding(8, 4)
        }
    }

    var dayEventsView: some View {
        HStack(spacing: customizationParams.horSpacing) {
            ForEach(0..<daysCount, id: \.self) { i in
                theme.day.separators.frame(width: 1)
                GeometryReader { g in
                    let date = selectedDate.adding(.day, value: i).startOfDay
                    DayEventsLayout(events: nonAllDayEventsByDay[date] ?? [], size: g.size, horSpacing: customizationParams.horSpacing, verSpacing: customizationParams.verSpacing, dayEventBuilder: dayEventBuilder)
                }
            }
        }
        .padding(.trailing, customizationParams.horSpacing)
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
