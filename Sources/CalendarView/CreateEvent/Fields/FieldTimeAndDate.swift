//
//  TimeAndDateView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct FieldTimeAndDate: View {
    enum PickersEnum: CaseIterable {
        case StartsDatePicker
        case StartsTimePicker
        case EndsDatePicker
        case EndsTimePicker
    }

    @Environment(\.calendarTheme) private var theme

    @Binding var isAllDay: Bool
    @Binding var startsDate: Date
    @Binding var endsDate: Date
    
    @State private var showStartsDatePicker: Bool = false
    @State private var showStartsTimePicker: Bool = false
    @State private var showEndsDatePicker: Bool = false
    @State private var showEndsTimePicker: Bool = false

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
                self.showEndsDatePicker = false
                self.showEndsTimePicker = false
                self.showStartsTimePicker = false
                self.showStartsDatePicker = false
            }
        }
    }

    func timeAndDateRow(text: String, isStartsDate: Bool) -> some View {
        let date = isStartsDate ? startsDate : endsDate

        return VStack {
            HStack {
                Text(text)

                Spacer()

                Text(date.dateFormat)
                    .padding(12, 6)
                    .background(Color.named("appLightGrey"))
                    .clipShape(Capsule())
                    .systemFont(17, .regular, theme.main.accent)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showPicker(isStartsDate ? .StartsDatePicker : .EndsDatePicker)
                        }
                    }

                if !isAllDay {
                    Text(date.timeFormat)
                        .padding(12, 6)
                        .background(Color.named("appLightGrey"))
                        .clipShape(Capsule())
                        .systemFont(17, .regular, theme.main.accent)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showPicker(isStartsDate ? .StartsTimePicker : .EndsTimePicker)
                            }
                        }
                }
            }

            if isStartsDate ? showStartsDatePicker : showEndsDatePicker {
                DatePicker(text, selection: isStartsDate ? $startsDate : $endsDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.graphical)
                    .tint(.blue.opacity(0.3))
            }

            if isStartsDate ? showStartsTimePicker : showEndsTimePicker {
                DatePicker(text, selection: isStartsDate ? $startsDate : $endsDate, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .tint(.blue.opacity(0.3))
            }
        }
        .clipped()
    }

    private func showPicker(_ picker: PickersEnum) {
        switch picker {
        case .StartsDatePicker:
            self.showEndsDatePicker = false
            self.showEndsTimePicker = false
            self.showStartsTimePicker = false
            self.showStartsDatePicker.toggle()
        case .StartsTimePicker:
            self.showEndsDatePicker = false
            self.showEndsTimePicker = false
            self.showStartsTimePicker.toggle()
            self.showStartsDatePicker = false
        case .EndsDatePicker:
            self.showEndsDatePicker.toggle()
            self.showEndsTimePicker = false
            self.showStartsTimePicker = false
            self.showStartsDatePicker = false
        case .EndsTimePicker:
            self.showEndsDatePicker = false
            self.showEndsTimePicker.toggle()
            self.showStartsTimePicker = false
            self.showStartsDatePicker = false
        }
    }
}
