//
//  TimeAndDateView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct FieldTimeAndDate: View {
    enum PickersEnum: CaseIterable {
        case none
        case startsDatePicker
        case startsTimePicker
        case endsDatePicker
        case endsTimePicker
    }

    @Environment(\.calendarTheme) private var theme

    @Binding var isAllDay: Bool
    @Binding var startsDate: Date
    @Binding var endsDate: Date

    @State private var displayedPicker: PickersEnum = .none

    @State private var height = CGFloat.zero

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Time and Date")

                    Spacer()

                    Text("All day")

                    Toggle("", isOn: $isAllDay)
                        .labelsHidden()
                        .padding(.trailing, 3)
                }

                timeAndDateRow(text: "Starts", isStartsDate: true)

                timeAndDateRow(text: "Ends", isStartsDate: false)
            }
            .onChange(of: isAllDay) { _,_ in
                self.displayedPicker = .none
            }
        }
    }

    func timeAndDateRow(text: String, isStartsDate: Bool) -> some View {
        let date = isStartsDate ? startsDate : endsDate

        return VStack {
            HStack {
                Text(text)

                Spacer()

                dateCell(title: date.dateFormat) {
                    showPicker(isStartsDate ? .startsDatePicker : .endsDatePicker)
                }

                if !isAllDay {
                    dateCell(title: date.timeFormat) {
                        showPicker(isStartsDate ? .startsTimePicker : .endsTimePicker)
                    }
                }
            }

            if isStartsDate ? displayedPicker == .startsDatePicker : displayedPicker == .endsDatePicker {
                DatePicker(text, selection: isStartsDate ? $startsDate : $endsDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(.blue.opacity(0.3))
            }

            if isStartsDate ? displayedPicker == .startsTimePicker : displayedPicker == .endsTimePicker {
                DatePicker(text, selection: isStartsDate ? $startsDate : $endsDate, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .tint(.blue.opacity(0.3))
            }
        }
        .clipped()
    }

    private func dateCell(title: String, onTap: @escaping ()->()) -> some View {
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

    private func showPicker(_ picker: PickersEnum) {
        displayedPicker = displayedPicker == picker ? .none : picker
    }
}
