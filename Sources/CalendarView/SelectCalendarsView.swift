//
//  SelectCalendarsView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 13.05.2025.
//

import SwiftUI

public struct SelectCalendarsView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: CalendarViewModel

    var calendarsGroupedBySection: [(key: String, value: [ProviderCalendar])] {
        Dictionary(grouping: viewModel.calendars, by: \.source)
            .sorted { $0.key.lowercased() < $1.key.lowercased() }
    }

    public var body: some View {
        VStack {
            ZStack {
                Text("Filter").systemFont(17, .semibold)
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .systemFont(17, .semibold, .accentColor)
                }
            }
            .padding(16)

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
        .background(Color("appLightBG", bundle: .module))
        .task {
            await viewModel.fetchCalendars()
        }
    }

    @ViewBuilder
    func calendarsSection(_ section: String, _ calendars: [ProviderCalendar]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(section)
                .systemFont(13, .semibold, Color("appGrey", bundle: .module))
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(calendars) { calendar in
                Button {
                    viewModel.toggleCalendar(calendar)
                } label: {
                    HStack {
                        ZStack {
                            RoundedRectangle.styled(4, calendar.color)
                                .size(20)
                            if viewModel.selectedCalendarIDs.contains(calendar.id) {
                                Image(.checkmark)
                                    .size(10)
                            }
                        }
                        Text(calendar.title).systemFont(14, Color("appBlack", bundle: .module))
                        Spacer()
                    }
                }

            }
        }
    }
}

