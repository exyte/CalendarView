//
//  CustomCalendar.swift
//  CalendarViewExample
//
//  Created by Alisa Mylnikova on 30.06.2026.
//

import SwiftUI
import CalendarView

struct CustomCalendar: View {
    @Environment(\.dismiss) private var dismiss

    @State private var fullscreenDate = Date().startOfDay
    private static let today = Date().startOfDay

    var body: some View {
        CalendarView(providers: CalendarDefaults.defaultProviders) { entity in
            squareDayEvent(entity)
        } monthDayBuilder: { params in
            squareMonthDay(params)
        } headerBuilder: { params in
            squareHeader(params)
        }
        .fullscreenDate($fullscreenDate)
        .firstDayOfWeek(2)
        .hoursToFit(8)
        .hourLabelFormat("HH:mm")
        .calendarTheme(.square)
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Day event builder

    @ViewBuilder
    private func squareDayEvent(_ entity: any CalendarEntity) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundStyle(entity.calendarColor.opacity(0.2))

            HStack(spacing: 0) {
                entity.calendarColor
                    .frame(width: 3)
                Text(entity.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.sqDark)
                    .padding(6, 4)
                Spacer()
            }
        }
    }

    // MARK: - Month day builder

    @ViewBuilder
    private func squareMonthDay(_ params: MonthDayBuilderParams) -> some View {
        let isToday = params.date.startOfDay == Self.today

        VStack(alignment: .leading, spacing: 4) {
            Color.sqBrown.opacity(0.2)
                .frame(height: 1)
                .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(params.date.getDay())")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.sqDark)

                if isToday {
                    Color.sqPeach
                        .frame(width: 20, height: 3)
                }
            }
            .padding(.horizontal, 4)

            VStack(spacing: 2) {
                ForEach(0..<min(3, params.events.count), id: \.self) { i in
                    let entity = params.events[i]
                    HStack(spacing: 0) {
                        entity.calendarColor
                            .frame(width: 3)
                        Text(entity.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.sqDark)
                            .greedyWidth()
                            .padding(.horizontal, 3)
                    }
                    .background(entity.calendarColor.opacity(0.2))
                }
            }

            Spacer()
        }
    }

    // MARK: - Week switcher day builder

    @ViewBuilder
    private func squareWeekDay(_ params: WeekSwitcherDayBuilderParams) -> some View {
        let isSelected = params.fullscreenDate == params.day
        let isToday = Self.today == params.day
        let isWeekend = params.day.isWeekend
        let textColor: Color = isSelected ? .sqCard : isWeekend ? .sqBrown : .sqDark

        VStack(spacing: 8) {
            if params.monthDisplayMode {
                Spacer()
                Text(params.day.formatted("EEE"))
                    .font(.system(size: 15))
                    .foregroundStyle(isWeekend ? Color.sqBrown : Color.sqDark)
                    .padding(.bottom, 10)
            } else {
                Text(params.day.formatted("EEE"))
                    .font(.system(size: 13))
                    .foregroundStyle(isWeekend ? Color.sqBrown : Color.sqDark)

                VStack(spacing: 2) {
                    Text(params.day.formatted("d"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(textColor)
                    if isToday {
                        (isSelected ? Color.sqCard.opacity(0.5) : Color.sqPeach)
                            .frame(width: 20, height: 3)
                    }
                }
                .frame(width: 36, height: 40)
                .background(isSelected ? Color.sqOlive : .clear)
            }
        }
    }

    // MARK: - Header builder

    @ViewBuilder
    private func squareHeader(_ params: HeaderBuilderParams) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "plus")
                            .rotationEffect(Angle(radians: CGFloat.pi * 1/4))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.sqCard)
                            .frame(width: 32, height: 32)
                            .background(Color.sqOlive)
                    }

                    Text(params.anchorDate.wrappedValue.formatted("MMMM yyyy"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.sqDark)

                    Spacer()

                    Button { params.tapFilterCalendarsClosure() } label: {
                        Text("Calendars")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.sqDark)
                            .padding(10, 6)
                            .background(Color.sqBrown.opacity(0.12))
                            .overlay(Rectangle().stroke(Color.sqBrown.opacity(0.3), lineWidth: 1))
                    }

                    Button { params.tapAddEventClosure() } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.sqCard)
                            .frame(width: 32, height: 32)
                            .background(Color.sqOlive)
                    }
                }
                .padding(.horizontal, 16)

                params.defaultWeekSwitcher { weekParams in
                    squareWeekDay(weekParams)
                }
                .padding(.horizontal, 4)
            }
            .padding(.top, 12)
            .padding(.bottom, 10)
            .background(Color.sqCream)

            HStack {
                Text(params.fullscreenDate.wrappedValue.formatted("d MMMM yyyy"))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.sqDark)

                if params.fullscreenDate.wrappedValue.startOfDay == Self.today {
                    Text("Today")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.sqPeach)
                }

                Spacer()

                Button {
                    let modes = [CalendarDisplayMode.day, .month]
                    let current = params.displayMode.wrappedValue
                    let idx = modes.firstIndex(of: current) ?? 0
                    params.displayMode.wrappedValue = modes[(idx + 1) % modes.count]
                } label: {
                    Text(params.displayMode.wrappedValue.title)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.sqDark)
                        .padding(10, 6)
                        .background(Color.sqBrown.opacity(0.12))
                        .overlay(Rectangle().stroke(Color.sqBrown.opacity(0.3), lineWidth: 1))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Color.sqCream
                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 3)
            )
        }
    }
}
