//
//  CreateCalendarView.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 08.07.2025.
//

import SwiftUI

struct CreateCalendarView: View {
    @EnvironmentObject var viewModel: CalendarViewModel

    @State private var calendar = ProviderCalendar()

    var body: some View {
        VStack {
            HStack {
                TextField("Title", text: $calendar.title)
                ColorPicker("", selection: $calendar.color)
            }

            Button {
                Task {
                    await viewModel.addCalendar(calendar)
                    calendar = ProviderCalendar()
                }
            } label: {
                Text("Create")
                    .systemFont(17, .semibold, calendar.title.isEmpty ? .gray : .green)
            }
            .disabled(calendar.title.isEmpty)
        }
    }
}
