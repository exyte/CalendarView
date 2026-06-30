//
//  DayLayout.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

public struct DayLayout<Content: View>: View {
    struct Grouped {
        var allDayEvents: [CalendarEvent] = []
        var nonAllDayEvents: [CalendarEvent] = []
        var allDayEventsByDay: [Date: [CalendarEvent]] = [:]
        var nonAllDayEventsByDay: [Date: [CalendarEvent]] = [:]
        var remindersByDay: [Date: [CalendarReminder]] = [:]

        static func compute(
            events: [CalendarEvent],
            reminders: [CalendarReminder],
            anchorDate: Date,
            daysCount: Int
        ) -> Grouped {
            let split = Dictionary(grouping: events, by: \.isAllDay)
            let allDay = split[true] ?? []
            let nonAllDay = split[false] ?? []

            var allDayByDay: [Date: [CalendarEvent]] = [:]
            if daysCount == 1 {
                allDayByDay[anchorDate] = allDay
            } else {
                for i in 0..<daysCount {
                    let dayStart = anchorDate.adding(.day, value: i).startOfDay
                    allDayByDay[dayStart] = allDay
                        .filter { $0.startDate <= dayStart && $0.endDate >= dayStart }
                        .sorted(by: \.id)
                }
            }
            return Grouped(
                allDayEvents: allDay,
                nonAllDayEvents: nonAllDay,
                allDayEventsByDay: allDayByDay,
                nonAllDayEventsByDay: daysCount == 1 ? [anchorDate: nonAllDay] : nonAllDay.groupedByDay(),
                remindersByDay: daysCount == 1 ? [anchorDate: reminders] : reminders.groupedByDay()
            )
        }
    }

    struct GroupingKey: Equatable {
        var events: [CalendarEvent]
        var reminders: [CalendarReminder]
        var anchorDate: Date
        var daysCount: Int
    }

    @Environment(\.calendarTheme) var theme
    @Environment(\.calendarCustomizationParams) var customizationParams
    @Environment(\.hoursFittingCurrentZoom) var hoursFittingCurrentZoom
    @Environment(\.showEventDetailsClosure) var showEventDetailsClosure

    @Binding var hoursLabelsInset: CGFloat
    @Binding var isCalendarScrolling: Bool

    var anchorDate: Date
    var daysCount: Int
    var events: [CalendarEvent]
    var reminders: [CalendarReminder]
    var isScrollDisabled: Bool
    var pinchAnchor: CGFloat = 0.5

    @ViewBuilder var dayEventBuilder: (any CalendarEntity) -> Content

    // MARK: - inner state

    @State private var grouped = Grouped()
    @State private var hourLabelsSize: CGSize = .zero
    @State private var hourTextHeight: CGFloat = 0

    var hoursToFit: CGFloat {
        hoursFittingCurrentZoom ?? customizationParams.hoursToFit
    }

    let allDaysViewMaxHeight = 90.0
    let horizontalPadding = 8.0

    public var body: some View {
        VStack(spacing: 4) {
            // all day events
            if !grouped.allDayEvents.isEmpty {
                allDayEventsView
                    .padding(.top, 10)
            }

            // events by hour
            GeometryReader { global in
                ScrollView {
                    HStack(spacing: 0) {
                        let oneHourHeight = global.size.height / CGFloat(hoursToFit)

                        hourLabels(oneHourHeight)
                            .padding(.horizontal, horizontalPadding)
                            .sizeGetter($hourLabelsSize)

                        ZStack(alignment: .top) {
                            separatorsView(oneHourHeight)
                            if anchorDate.getDateWithoutTime() == Date().getDateWithoutTime() {
                                nowLine(oneHourHeight)
                            }
                            dayEventsAndRemindersView(availableWidth: max(0, global.size.width - hourLabelsSize.width), oneHourHeight: oneHourHeight)
                        }
                        .padding(.top, hourTextHeight + 8)
                    }
                }
                .contentMargins(.trailing, horizontalPadding, for: .scrollIndicators)
                .scrollDisabled(isScrollDisabled)
                .modifier(DayScrollModifier(
                    isCalendarScrolling: $isCalendarScrolling,
                    isScrollDisabled: isScrollDisabled,
                    pinchAnchor: pinchAnchor,
                    hourTextHeight: hourTextHeight,
                    containerHeight: global.size.height,
                    anchorDate: anchorDate
                ))
            }
        }
        .onChange(of: hourLabelsSize) {
            hoursLabelsInset = hourLabelsSize.width + 2 * horizontalPadding
        }
        .task(id: GroupingKey(events: events, reminders: reminders, anchorDate: anchorDate, daysCount: daysCount)) {
            grouped = Grouped.compute(events: events, reminders: reminders, anchorDate: anchorDate, daysCount: daysCount)
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
                        let events = grouped.allDayEventsByDay[date] ?? []
                        let eventsCount = events.count
                        if events.isEmpty {
                            Color.clear.frame(height: 1)
                        } else {
                            ForEach(Array(stride(from: 0, to: eventsCount, by: 2)), id: \.self) { index in
                                HStack(spacing: spaceBetweenDays) {
                                    allDayEventsBuilderView(event: events[index])
                                    if index + 1 < eventsCount {
                                        allDayEventsBuilderView(event: events[index + 1])
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: allDaysViewMaxHeight)
                .scrollBounceBehavior(.basedOnSize)
                .scrollDisabled(isScrollDisabled)
                .onScrollPhaseChange { _, newVal in
                    isCalendarScrolling = newVal != .idle
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.trailing, customizationParams.horSpacing)
        // can't be a part of layout to be able to align 3-day view correctly
        .overlay(alignment: .topLeading) {
            Text("all-day")
                .systemFont(13, theme.day.hourText)
                .padding(8, 4)
        }
    }

    private func allDayEventsBuilderView(event: CalendarEvent) -> some View {
        dayEventBuilder(event)
            .frame(height: 30)
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture {
                showEventDetailsClosure(event)
            }
    }

    func dayEventsAndRemindersView(availableWidth: CGFloat, oneHourHeight: CGFloat) -> some View {
        // each day cell: 1pt separator + cell. trailing padding is one horSpacing.
        // cells share the remaining width equally.
        let separators = CGFloat(daysCount)
        let trailingPadding = customizationParams.horSpacing
        let interCellSpacing = customizationParams.horSpacing * CGFloat(max(0, daysCount - 1))
        let cellWidth = max(0, (availableWidth - separators - interCellSpacing - trailingPadding) / CGFloat(daysCount))
        return HStack(spacing: customizationParams.horSpacing) {
            ForEach(0..<daysCount, id: \.self) { i in
                theme.day.separators.frame(width: 1)
                let date = anchorDate.adding(.day, value: i).startOfDay
                DayEventsLayout(
                    events: grouped.nonAllDayEventsByDay[date] ?? [],
                    reminders: grouped.remindersByDay[date] ?? [],
                    oneHourHeight: oneHourHeight,
                    horSpacing: customizationParams.horSpacing,
                    verSpacing: customizationParams.verSpacing,
                    trailingPadding: customizationParams.horSpacing,
                    dayEventBuilder: dayEventBuilder
                )
                .frame(width: cellWidth)
            }
        }
        .padding(.trailing, customizationParams.horSpacing)
    }

    private func startCoeff(_ date: Date) -> CGFloat {
        CGFloat((date.getHour() * 60 + date.getMinute())) / CGFloat(60)
    }
}

// MARK: - Scroll modifier

private struct DayScrollModifier: ViewModifier {
    struct ScrollInfo: Equatable {
        let yOffset: CGFloat
        let maxOffset: CGFloat
    }

    @Environment(\.hoursFittingCurrentZoom) var hoursFittingCurrentZoom
    @Environment(\.calendarCustomizationParams) var customizationParams

    @Binding var isCalendarScrolling: Bool

    var isScrollDisabled: Bool
    var pinchAnchor: CGFloat
    var hourTextHeight: CGFloat
    var containerHeight: CGFloat
    var anchorDate: Date

    @State private var scrollPosition = ScrollPosition()
    @State private var targetOffset = CGFloat.zero
    @State private var scrollInfo = ScrollInfo(yOffset: 0, maxOffset: 100)

    func body(content: Content) -> some View {
        content
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
                isCalendarScrolling = newVal != .idle
            }
            .onChange(of: hoursFittingCurrentZoom) { oldZoom, newZoom in
                guard isScrollDisabled else { return }
                var t = Transaction()
                t.disablesAnimations = true
                withTransaction(t) {
                    let focalY = max(0, min(containerHeight, pinchAnchor * containerHeight))
                    let centerY = scrollInfo.yOffset + focalY
                    let hoursOld = oldZoom ?? customizationParams.hoursToFit
                    let hoursNew = newZoom ?? customizationParams.hoursToFit
                    let oneHourOld = containerHeight / max(3.0, min(12.0, hoursOld))
                    let oneHourNew = containerHeight / max(3.0, min(12.0, hoursNew))
                    let hourIndexAtFocal = max(0, min(24, (centerY - hourTextHeight) / oneHourOld))
                    let newCenterY = hourIndexAtFocal * oneHourNew + hourTextHeight
                    targetOffset = max(0, min(newCenterY - focalY, scrollInfo.maxOffset)).rounded()
                    scrollPosition.scrollTo(y: targetOffset)
                }
            }
            .onChange(of: scrollInfo) {
                if isScrollDisabled {
                    let clamped = max(0, min(targetOffset, scrollInfo.maxOffset))
                    if clamped != targetOffset {
                        targetOffset = clamped
                    }
                }
            }
            .task(id: targetOffset) {
                if !isCalendarScrolling && targetOffset != scrollInfo.yOffset {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        scrollPosition.scrollTo(y: targetOffset)
                    }
                }
            }
            .task(id: scrollInfo) {
                if isCalendarScrolling {
                    let yOffset = max(0, min(scrollInfo.yOffset.rounded(), scrollInfo.maxOffset))
                    if yOffset != targetOffset {
                        targetOffset = yOffset
                    }
                }
            }
            .task(id: anchorDate) {
                // needs to scroll to first visible event when first opening this date
//                if let firstOccupiedHour = newGrouped.nonAllDayEvents.map { $0.startDate.getHour() }.min() {
//                    //scrollPosition set to firstOccupiedHour
//                    proxy.scrollTo(firstOccupiedHour, anchor: .top)
//                } else {
//                    scrollPosition.scrollTo(y: 0)
//                    //targetOffset = 0
//                }
            }
    }
}

// MARK: - Extensions

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
