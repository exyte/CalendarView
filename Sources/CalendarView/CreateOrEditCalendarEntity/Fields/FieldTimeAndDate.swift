//
//  FieldTimeAndDate.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

/// Date row stacked on a time row

struct FieldTimeAndDate: View {
    @Environment(\.calendarTheme) var theme
    @Binding var isAllDay: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date

    @State private var displayedPicker: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Time and Date")
                    .libraryFont(17, theme.main.secondaryText)

                Spacer()

                Text("All day")
                    .libraryFont(17, theme.main.secondaryText.opacity(0.6))

                CustomToggle(isOn: $isAllDay, onColor: theme.main.accent, offColor: theme.main.fieldBackground)
            }

            TimeAndDateRow(
                displayedPicker: $displayedPicker,
                date: $startDate,
                label: "Starts",
                mode: isAllDay ? .dateOnly : .dateAndTime
            )
            TimeAndDateRow(
                displayedPicker: $displayedPicker,
                date: $endDate,
                label: "Ends",
                mode: isAllDay ? .dateOnly : .dateAndTime
            )
        }
        .onChange(of: isAllDay) { _, _ in
            displayedPicker = nil
        }
    }
}

/// Date row stacked on a time row

struct FieldTimeOrDate: View {
    @Binding var date: Date

    @State private var displayedPicker: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TimeAndDateRow(displayedPicker: $displayedPicker, date: $date, label: "Date", mode: .dateOnly)
            TimeAndDateRow(displayedPicker: $displayedPicker, date: $date, label: "Time", mode: .timeOnly)
        }
    }
}

struct TimeAndDateRow: View {
    enum Mode {
        case dateAndTime
        case dateOnly
        case timeOnly

        var showsDate: Bool { self != .timeOnly }
        var showsTime: Bool { self != .dateOnly }
    }

    enum PickerKind { case date, time }

    @Environment(\.calendarTheme) var theme

    @Binding var displayedPicker: String?
    @Binding var date: Date

    var label: String
    var mode: Mode = .dateAndTime

    @State private var openKind: PickerKind?

    var isCurrentlyDisplayed: Bool { displayedPicker == label }

    var body: some View {
        VStack {
            HStack {
                Text(label)
                    .libraryFont(17, theme.main.secondaryText)

                Spacer()

                if mode.showsDate {
                    dateCell(title: dateTitle) {
                        toggle(.date)
                    }
                }

                if mode.showsTime {
                    dateCell(title: date.timeFormat) {
                        toggle(.time)
                    }
                }
            }

            if isCurrentlyDisplayed, openKind == .date {
                DatePicker(label, selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.graphical)
            }

            if isCurrentlyDisplayed, openKind == .time {
                DatePicker(label, selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
            }
        }
        .tint(theme.main.accentLight)
        .clipped()
        .onChange(of: displayedPicker) { _, newValue in
            if newValue != label { openKind = nil }
        }
    }

    private var dateTitle: String {
        if mode.showsTime { return date.dateFormat }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInTomorrow(date) { return "Tomorrow" }
        return date.dateFormat
    }

    private func dateCell(title: String, onTap: @escaping () -> Void) -> some View {
        Text(title)
            .padding(12, 6)
            .background(theme.main.fieldBackground)
            .clipShape(Capsule())
            .libraryFont(17, theme.main.accent)
            .onTapGesture {
                withAnimation(.easeInOut) {
                    onTap()
                }
            }
    }

    private func toggle(_ pickerKind: PickerKind) {
        if isCurrentlyDisplayed, openKind == pickerKind {
            openKind = nil
            displayedPicker = nil
        } else {
            openKind = pickerKind
            displayedPicker = label
        }
    }
}
