//
//  PublicInit.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.06.2026.
//

import SwiftUI

public extension CalendarView where WeekSwitcherDay == EmptyView {
    init(
        providers: [CalendarsProvider] = CalendarDefaults.defaultProviders,
        dayEventBuilder: @escaping (_ calendarEvent: any CalendarEntity) -> DayEvent = {
            DefaultDayEventView(entity: $0)
        },
        monthDayBuilder: @escaping (_ params: MonthDayBuilderParams) -> MonthDay = {
            DefaultDayInMonthView(params: $0)
        },
        headerBuilder: @escaping (_ params: HeaderBuilderParams) -> Header
    ) {
        self.init(
            providers: providers,
            dayEventBuilder: dayEventBuilder,
            monthDayBuilder: monthDayBuilder,
            weekSwitcherDayBuilder: { _ in EmptyView() },
            headerBuilder: headerBuilder
        )
    }
}

public extension CalendarView where Header == DefaultHeaderView {
    init(
        providers: [CalendarsProvider] = CalendarDefaults.defaultProviders,
        dayEventBuilder: @escaping (_ calendarEvent: any CalendarEntity) -> DayEvent = {
            DefaultDayEventView(entity: $0)
        },
        monthDayBuilder: @escaping (_ params: MonthDayBuilderParams) -> MonthDay = {
            DefaultDayInMonthView(params: $0)
        },
        weekSwitcherDayBuilder: @escaping (_ params: WeekSwitcherDayBuilderParams) -> WeekSwitcherDay
    ) {
        self.init(
            providers: providers,
            dayEventBuilder: dayEventBuilder,
            monthDayBuilder: monthDayBuilder,
            weekSwitcherDayBuilder: weekSwitcherDayBuilder,
            headerBuilder: { DefaultHeaderView(params: $0) }
        )
    }
}

public extension CalendarView where WeekSwitcherDay == EmptyView, Header == DefaultHeaderView {
    init(
        providers: [CalendarsProvider] = CalendarDefaults.defaultProviders,
        dayEventBuilder: @escaping (_ calendarEvent: any CalendarEntity) -> DayEvent = {
            DefaultDayEventView(entity: $0)
        },
        monthDayBuilder: @escaping (_ params: MonthDayBuilderParams) -> MonthDay = {
            DefaultDayInMonthView(params: $0)
        }
    ) {
        self.init(
            providers: providers,
            dayEventBuilder: dayEventBuilder,
            monthDayBuilder: monthDayBuilder,
            weekSwitcherDayBuilder: { _ in EmptyView() },
            headerBuilder: { DefaultHeaderView(params: $0) }
        )
    }
}
