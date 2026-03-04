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

    @Binding var hoursLabelsInset: CGFloat

    var anchorDate: Date
    var daysCount: Int
    var events: [CalendarEvent]
    var reminders: [CalendarReminder]
    var isScrollDisabled: Bool
    var updateID: UUID

    @ViewBuilder var dayEventBuilder: (any CalendarEntity)->Content
    
    private struct ScrollInfo: Equatable {
        let yOffset: CGFloat
        let maxOffset: CGFloat
    }

    @State private var scrollPosition = ScrollPosition()
    @State private var targetOffset = CGFloat.zero
    @State private var scrollInfo: ScrollInfo = ScrollInfo(yOffset: 0, maxOffset: 100)
    @State private var isScrolling = false

    init(hoursLabelsInset: Binding<CGFloat>, anchorDate: Date, daysCount: Int, events: [CalendarEvent], reminders: [CalendarReminder], isScrollDisabled: Bool, updateID: UUID, dayEventBuilder: @escaping (any CalendarEntity) -> Content) {
        self._hoursLabelsInset = hoursLabelsInset
        self.anchorDate = anchorDate
        self.daysCount = daysCount
        self.events = events
        self.reminders = reminders
        self.updateID = updateID
        self.isScrollDisabled = isScrollDisabled
        self.dayEventBuilder = dayEventBuilder

        let isAllDayGrouped = Dictionary(grouping: events, by: \.isAllDay)
        self.allDayEvents = isAllDayGrouped[true] ?? []
        self.nonAllDayEvents = isAllDayGrouped[false] ?? []
        self.nonAllDayEventsByDay = daysCount == 1 ? [anchorDate: nonAllDayEvents] : nonAllDayEvents.groupedByDay()
        self.allDayEventsByDay = daysCount == 1 ? [anchorDate: allDayEvents] : getAllDayEventsByDate()
        self.remindersByDay = daysCount == 1 ? [anchorDate: reminders] : reminders.groupedByDay()
    }
    
    private let allDaysViewMaxHeight: CGFloat = 90.0

    @State private var hourLabelsSize: CGSize = .zero
    @State private var hourTextHeight: CGFloat = 0
    @State private var allDaysViewHeight: [Int: CGFloat] = [0:0]

    var firstOccupiedHour: Int {
        nonAllDayEvents.map { $0.startDate.getHour() } .min { $0 < $1 } ?? 0
    }

    var allDayEvents: [CalendarEvent]
    var allDayEventsByDay: [Date: [CalendarEvent]] = [:]
    var nonAllDayEvents: [CalendarEvent]
    var nonAllDayEventsByDay: [Date: [CalendarEvent]] = [:]
    var remindersByDay: [Date: [CalendarReminder]] = [:]

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
                                if anchorDate.getDateWithoutTime() == Date().getDateWithoutTime() {
                                    nowLine(oneHourHeight)
                                }
                                dayEventsAndRemindersView
                            }
                            .padding(.top, hourTextHeight)
                        }
                    }
                    .scrollDisabled(isScrollDisabled)
                    .onChange(of: updateID) {
                        if !isScrollDisabled {
                            proxy.scrollTo(firstOccupiedHour, anchor: .top)
                        }
                    }
                    .onChange(of: scrollInfo, { old, new in
                        if isScrollDisabled {
                            let offset = targetOffset + (new.maxOffset - old.maxOffset) / 2
                            let yOffset = max(0, min(offset.rounded(), scrollInfo.maxOffset))
                            if yOffset != targetOffset {
                                targetOffset = yOffset
                            }
                        }
                    })
                    .scrollPosition($scrollPosition, anchor: .topLeading)
                    .onScrollGeometryChange(for: ScrollInfo.self) { geo in
                        ScrollInfo(
                            yOffset: geo.contentOffset.y + geo.contentInsets.top,
                            maxOffset: geo.contentSize.height - geo.containerSize.height
                        )
                    } action: { _, newVal in
                        scrollInfo = newVal
                    }
                    .onScrollPhaseChange { _, newVal in
                        isScrolling = newVal != .idle
                    }
                    .task(id: targetOffset) {
                        if !isScrolling && targetOffset != scrollInfo.yOffset {
                            scrollPosition.scrollTo(y: targetOffset)
                        }
                    }
                    .task(id: scrollInfo) {
                        if isScrolling {
                            let yOffset = max(0, min(scrollInfo.yOffset.rounded(), scrollInfo.maxOffset))
                            if yOffset != targetOffset {
                                targetOffset = yOffset
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: hourLabelsSize) {
            hoursLabelsInset = hourLabelsSize.width + 2 * horizontalPadding
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
        HStack(alignment: .top, spacing: customizationParams.horSpacing) {
            Color.clear.frame(width: max(0, hoursLabelsInset - spaceBetweenDays), height: 1)

            ForEach(0..<daysCount, id: \.self) { i in
                let date = anchorDate.adding(.day, value: i).startOfDay
                ScrollView {
                    VStack {
                        let events = allDayEventsByDay[date] ?? []
                        let eventsCount = events.count
                        if events.isEmpty {
                            Color.clear.frame(height: 1)
                        } else {
                            ForEach(Array(stride(from: 0, to: eventsCount, by: 2)), id: \.self) { index in
                                HStack(spacing: spaceBetweenDays) {
                                    allDayEventsBuilderView(index: index, events: events)
                                    if index + 1 < eventsCount {
                                        allDayEventsBuilderView(index: index + 1, events: events)
                                    }
                                }
                            }
                        }
                    }
                    .background {
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                self.allDaysViewHeight[i] = geo.size.height
                            }
                            return Color.clear
                        }
                    }
                }
                .frame(height: min(allDaysViewHeight.values.max() ?? 0, allDaysViewMaxHeight))
                .scrollBounceBehavior(.basedOnSize)
                .scrollDisabled(isScrollDisabled)
            }
        }
        .padding(.trailing, customizationParams.horSpacing)
        // can't be a part of layout to be able to align 3-day view correctly
        .overlay(alignment: .topLeading) {
            Text("all-day")
                .systemFont(13, theme.day.hourText)
                .padding(8, 4)
        }
    }

    private func allDayEventsBuilderView(index: Int, events: [CalendarEvent]) -> some View {
        dayEventBuilder(events[index])
            .frame(height: 30)
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture {
                showEventDetailsClosure(events[index])
            }
    }

    var dayEventsAndRemindersView: some View {
        HStack(spacing: customizationParams.horSpacing) {
            ForEach(0..<daysCount, id: \.self) { i in
                theme.day.separators.frame(width: 1)
                GeometryReader { g in
                    let date = anchorDate.adding(.day, value: i).startOfDay
                    DayEventsLayout(events: nonAllDayEventsByDay[date] ?? [], reminders: remindersByDay[date] ?? [], size: g.size, horSpacing: customizationParams.horSpacing, verSpacing: customizationParams.verSpacing, dayEventBuilder: dayEventBuilder)
                }
            }
        }
        .padding(.trailing, customizationParams.horSpacing)
    }

    private func startCoeff(_ date: Date) -> CGFloat {
        CGFloat((date.getHour() * 60 + date.getMinute())) / CGFloat(60)
    }
    
    private func getAllDayEventsByDate() -> [Date: [CalendarEvent]] {
        var allDayEventsByDay: [Date: [CalendarEvent]] = [:]
        for i in 0..<daysCount {
            let date = anchorDate.adding(.day, value: i)
            let interval = CalendarDisplayMode.day.interval(date)
            let startDate = interval.start
            let endDate = interval.end
            let allDayEvents = allDayEvents
                .filter{ $0.startDate <= startDate && $0.endDate >= startDate }
            
            allDayEventsByDay[date.startOfDay] = Array(Set(allDayEvents)).sorted(by: \.id)
        }
        
        return allDayEventsByDay
    }
}

extension Sequence where Element == CalendarEvent {
    func groupedByDay() -> [Date: [CalendarEvent]] {
        Dictionary(grouping: self) {
            $0.startDate.startOfDay
        }
    }
}

extension Sequence where Element == CalendarReminder {
    func groupedByDay() -> [Date: [CalendarReminder]] {
        Dictionary(grouping: self) {
            $0.startDate.startOfDay
        }
    }
}
