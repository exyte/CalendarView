//
//  FieldCalendarSelection.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 07.07.2025.
//

import SwiftUI

struct FieldCalendarSelection: View {
    @Environment(\.calendarTheme) var theme
    @Environment(CalendarViewModel.self) var viewModel
    @Binding var selectedCalendar: ProviderCalendar?

    @State private var showSelectionPopup: Bool = false

    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 0) {
                Text("Calendar")
                    .libraryFont(17, theme.main.secondaryText)

                Text("*")
                    .libraryFont(17, .red)
                    .padding(.leading, 4)

                Spacer()
            }

            Spacer()

            if let title = selectedCalendar?.title {
                Text(title)
                    .libraryFont(17, theme.main.text)
                    .padding(12, 4)
                    .background(Color(selectedCalendar?.color ?? .clear).opacity(0.3))
                    .cornerRadius(17)
            } else {
                Text("Not selected")
                    .libraryFont(17, theme.main.secondaryText.opacity(0.6))
            }

            Image(systemName: "chevron.right")
                .libraryFont(15, .semibold, theme.main.tertiaryText.opacity(0.3))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showSelectionPopup = true
        }
        .sheet(isPresented: $showSelectionPopup) {
            CalendarSelectionSheetView(selectedCalendar: $selectedCalendar)
                .environment(viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct CalendarSelectionSheetView: View {
    @Environment(\.calendarTheme) var theme
    @Environment(\.dismiss) var dismiss
    @Environment(CalendarViewModel.self) var viewModel

    @Binding var selectedCalendar: ProviderCalendar?

    var body: some View {
        VStack(spacing: 20) {
            Text("Select calendar")
                .libraryFont(17, .semibold, theme.main.text)

            ForEach(viewModel.calendars) { calendar in
                HStack {
                    Circle()
                        .foregroundStyle(calendar.color)
                        .size(10)

                    Text(calendar.title)
                        .libraryFont(17, theme.main.text)

                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedCalendar = calendar
                    dismiss()
                }
            }

            Spacer()
        }
        .padding(20, 30)
    }
}
