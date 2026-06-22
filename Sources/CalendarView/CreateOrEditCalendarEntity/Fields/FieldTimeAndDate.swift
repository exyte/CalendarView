//
//  TimeAndDateView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

enum PickersEnum: CaseIterable {
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

    @State private var displayedPicker: PickersEnum?

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

            TimeAndDateRow(kind: .starts, date: $startDate, showTime: !isAllDay, displayedPicker: $displayedPicker)
            TimeAndDateRow(kind: .ends,   date: $endDate,   showTime: !isAllDay, displayedPicker: $displayedPicker)
        }
        .onChange(of: isAllDay) { _, _ in
            displayedPicker = nil
        }
    }
}

struct TimeAndDateRow: View {
    private enum PickerKind { case date, time }

    @Environment(\.calendarTheme) private var theme

    let kind: PickersEnum
    @Binding var date: Date
    let showTime: Bool
    @Binding var displayedPicker: PickersEnum?

    @State private var openKind: PickerKind?

    private var isMine: Bool { displayedPicker == kind }

    var body: some View {
        VStack {
            HStack {
                Text(kind.label)

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

            if isMine, openKind == .date {
                DatePicker(kind.label, selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(.blue.opacity(0.3))
            }

            if isMine, openKind == .time {
                DatePicker(kind.label, selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .tint(.blue.opacity(0.3))
            }
        }
        .clipped()
        .onChange(of: displayedPicker) { _, newValue in
            if newValue != kind { openKind = nil }
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
        if isMine, openKind == pickerKind {
            openKind = nil
            displayedPicker = nil
        } else {
            openKind = pickerKind
            displayedPicker = kind
        }
    }
}
