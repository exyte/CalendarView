//
//  SelectCalendarsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 13.05.2025.
//

import SwiftUI

public struct FilterCalendarsView: View {
    @Environment(\.calendarTheme) var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(CalendarViewModel.self) var viewModel

    var calendarsGroupedBySection: [(key: String, value: [ProviderCalendar])] {
        Dictionary(grouping: viewModel.calendars, by: \.source)
            .sorted { $0.key.lowercased() < $1.key.lowercased() }
    }

    public var body: some View {
        VStack {
            CloseSaveHeaderView(title: "Filter")

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(calendarsGroupedBySection, id: \.key) { section, calendars in
                        calendarsSection(section, calendars)
                            .padding(20, 32)
                            .background(RoundedRectangle.styled(24, theme.main.cardBackground))
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(theme.main.background)
        .task {
            await viewModel.fetchCalendars()
        }
    }

    @ViewBuilder
    func calendarsSection(_ section: String, _ calendars: [ProviderCalendar]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(section)
                .systemFont(13, .semibold, theme.main.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(calendars) { calendar in
                Button {
                    viewModel.toggleCalendar(calendar)
                } label: {
                    HStack {
                        ZStack {
                            RoundedRectangle.styled(4, calendar.color)
                                .size(20)
                            if viewModel.isCalendarSelected(calendar) {
                                Image(.checkmark)
                                    .size(10)
                            }
                        }
                        Text(calendar.title)
                            .systemFont(14, theme.main.text)
                        Spacer()
                    }
                }
            }
        }
    }
}

