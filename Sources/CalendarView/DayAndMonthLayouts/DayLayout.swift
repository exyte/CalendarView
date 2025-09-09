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
    @Environment(\.showEventDetailsClosure) var showEventDetailsClosure

    @Binding var selectedDate: Date
    @Binding var hoursLabelsInset: CGFloat
    var daysCount: Int
    var events: [CalendarEvent]
    var reminders: [CalendarReminder]
    var updateID: UUID
    @ViewBuilder var dayEventBuilder: (any CalendarEntity)->Content
    
    var currentDate: Date
    @Binding var isDragging: Bool

    init(selectedDate: Binding<Date>, currentDate: Date, hoursLabelsInset: Binding<CGFloat>, daysCount: Int, events: [CalendarEvent], reminders: [CalendarReminder], updateID: UUID, isDragging: Binding<Bool>, dayEventBuilder: @escaping (any CalendarEntity) -> Content) {
        self._selectedDate = selectedDate
        self.currentDate = currentDate
        self._hoursLabelsInset = hoursLabelsInset
        self.daysCount = daysCount
        self.events = events
        self.reminders = reminders
        self.updateID = updateID
        self.dayEventBuilder = dayEventBuilder
        self._isDragging = isDragging

        let isAllDayGrouped = Dictionary(grouping: events, by: \.isAllDay)
        self.allDayEvents = isAllDayGrouped[true] ?? []
        self.allDayEventsByDay = daysCount == 1 ? [currentDate: allDayEvents] : allDayEvents.groupedByDay()
        self.nonAllDayEvents = isAllDayGrouped[false] ?? []
        self.nonAllDayEventsByDay = daysCount == 1 ? [currentDate: nonAllDayEvents] : nonAllDayEvents.groupedByDay()
    }
    
    private let allDaysViewMaxHeight: CGFloat = 90.0

    @State private var hourLabelsSize: CGSize = .zero
    @State private var hourTextHeight: CGFloat = 0
    @State private var allDaysViewHeight: CGFloat = 0

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
                                if currentDate.getDateWithoutTime() == Date().getDateWithoutTime() {
                                    nowLine(oneHourHeight)
                                }
                                dayEventsAndRemindersView
                            }
                            .padding(.top, hourTextHeight)
                        }
                    }
                    .scrollDisabled(isDragging)
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
                    .maxHeightGetter($hourTextHeight)
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
            Color.clear.frame(width: max(0, hoursLabelsInset - spaceBetweenDays), height: 1)

            ForEach(0..<daysCount, id: \.self) { i in
                let date = currentDate.adding(.day, value: i).startOfDay
                ScrollView {
                    VStack {
                        let events = allDayEventsByDay[date] ?? []
                        let eventsCount = events.count
                        if events.isEmpty {
                            Color.clear.frame(height: 1)
                        } else {
                            ForEach(Array(stride(from: 0, to: eventsCount, by: 2)), id: \.self) { index in
                                HStack(spacing: spaceBetweenDays) {
                                    dayEventBuilder(events[index])
                                        .fixedSize(horizontal: false, vertical: true)
                                        .onTapGesture {
                                            showEventDetailsClosure(events[index])
                                        }
                                    if index + 1 < eventsCount {
                                        dayEventBuilder(events[index + 1])
                                            .fixedSize(horizontal: false, vertical: true)
                                            .onTapGesture {
                                                showEventDetailsClosure(events[index + 1])
                                            }
                                    }
                                }
                            }
                            
                        }
                    }
                    .background(GeometryReader {geo -> Color in
                        DispatchQueue.main.async {
                            self.allDaysViewHeight = geo.size.height
                        }
                        return Color.clear
                    })
                }
                .frame(height: min(allDaysViewHeight, allDaysViewMaxHeight))
                .scrollBounceBehavior(.basedOnSize)
                .scrollDisabled(isDragging)
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

    var dayEventsAndRemindersView: some View {
        HStack(spacing: customizationParams.horSpacing) {
            ForEach(0..<daysCount, id: \.self) { i in
                theme.day.separators.frame(width: 1)
                GeometryReader { g in
                    let date = currentDate.adding(.day, value: i).startOfDay
                    DayEventsLayout(events: nonAllDayEventsByDay[date] ?? [], reminders: reminders, size: g.size, horSpacing: customizationParams.horSpacing, verSpacing: customizationParams.verSpacing, dayEventBuilder: dayEventBuilder)
                }
            }
        }
        .padding(.trailing, customizationParams.horSpacing)
    }

    private func startCoeff(_ date: Date) -> CGFloat {
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
