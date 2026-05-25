//
//  SelectCalendarsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 13.05.2025.
//

import SwiftUI

public struct SelectCalendarsView: View {
    @Environment(\.calendarTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: CalendarViewModel

    var calendarsGroupedBySection: [(key: String, value: [ProviderCalendar])] {
        Dictionary(grouping: viewModel.calendars, by: \.source)
            .sorted { $0.key.lowercased() < $1.key.lowercased() }
    }

    public var body: some View {
        VStack {
            headerView

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(calendarsGroupedBySection, id: \.key) { section, calendars in
                        calendarsSection(section, calendars)
                            .padding(20, 32)
                            .background(RoundedRectangle.styled(24, .white))
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

    var headerView: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(.cross)
                }
                .frame(width: 44, height: 44)
                .background(Circle().styled(theme.button.background))

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(.checkmark)
                        .resizable()
                        .frame(width: 14, height: 12)
                }
                .frame(width: 44, height: 44)
                .background(Circle().styled(theme.button.accent))
            }

            Text("Filter").systemFont(17, .semibold, theme.main.text)
        }
        .padding(16)
        .overlay {
            VStack {
                Capsule()
                    .frame(width: 36, height: 5)
                    .foregroundStyle(theme.main.secondaryText)
                    .padding(.top, 5)

                Spacer()
            }
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
                        Text(calendar.title).systemFont(14, theme.main.text)
                        Spacer()
                    }
                }
            }
        }
    }
}

