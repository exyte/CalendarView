//
//  FieldTimeAndDate.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

enum PickerDateType: CaseIterable {
    case starts
    case ends

    var label: String {
        switch self {
        case .starts: "Starts"
        case .ends:   "Ends"
        }
    }
}

struct FieldTimeAndDate: View {
    @Binding var isAllDay: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date

    @State var displayedPicker: PickerDateType?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Time and Date")

                Spacer()

                Text("All day")

                Toggle("", isOn: $isAllDay)
                    .labelsHidden()
                    .padding(.trailing, 3)
            }

            TimeAndDateRow(displayedPicker: $displayedPicker, date: $startDate, pickerDateType: .starts, showTime: !isAllDay)
            TimeAndDateRow(displayedPicker: $displayedPicker, date: $endDate, pickerDateType: .ends, showTime: !isAllDay)
        }
        .onChange(of: isAllDay) { _, _ in
            displayedPicker = nil
        }
    }
}

struct TimeAndDateRow: View {
    enum PickerKind { case date, time }

    @Environment(\.calendarTheme) private var theme

    @Binding var displayedPicker: PickerDateType?
    @Binding var date: Date
    var pickerDateType: PickerDateType
    var showTime: Bool

    @State var openKind: PickerKind?

    var isCurrentlyDisplayed: Bool { displayedPicker == pickerDateType }

    var body: some View {
        VStack {
            HStack {
                Text(pickerDateType.label)

                Spacer()

                dateCell(title: date.dateFormat) {
                    toggle(.date)
                }

                if showTime {
                    dateCell(title: date.timeFormat) {
                        toggle(.time)
                    }
                }
            }

            if isCurrentlyDisplayed, openKind == .date {
                DatePicker(pickerDateType.label, selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(.blue.opacity(0.3))
            }

            if isCurrentlyDisplayed, openKind == .time {
                DatePicker(pickerDateType.label, selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .tint(.blue.opacity(0.3))
            }
        }
        .clipped()
        .onChange(of: displayedPicker) { _, newValue in
            if newValue != pickerDateType { openKind = nil }
        }
    }

    private func dateCell(title: String, onTap: @escaping () -> Void) -> some View {
        Text(title)
            .padding(12, 6)
            .background(Color.named("appLightGrey"))
            .clipShape(Capsule())
            .systemFont(17, .regular, theme.main.accent)
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
            displayedPicker = pickerDateType
        }
    }
}
