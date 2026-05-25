//
//  TimeAndDateView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct FieldTimeAndDate: View {
    @Environment(\.calendarTheme) private var theme

    @Binding var isAllDay: Bool
    @Binding var startsDay: Date
    @Binding var endsDay: Date
    
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

                VStack {
                    HStack {
                        Text("Starts")

                        Spacer()

                        Text(startsDay.formatted("d MMM yyyy"))
                            .frame(height: 34)
                            .padding(.horizontal, 12)
                            .background(Color.named("appLightGrey"))
                            .cornerRadius(17)
                            .systemFont(17, .regular, theme.main.accent)
                            .gesture(TapGesture().onEnded({
                                withAnimation(.easeInOut) {
                                    self.showEndsDatePicker = false
                                    self.showEndsTimePicker = false
                                    self.showStartsTimePicker = false
                                    self.showStartsDatePicker.toggle()
                                }
                            }))

                        if !isAllDay {
                            Text(startsDay.formatted("HH:mm"))
                                .frame(height: 34)
                                .padding(.horizontal, 12)
                                .background(Color.named("appLightGrey"))
                                .cornerRadius(17)
                                .systemFont(17, .regular, theme.main.accent)
                                .gesture(TapGesture().onEnded({
                                    withAnimation(.easeInOut) {
                                        self.showEndsDatePicker = false
                                        self.showEndsTimePicker = false
                                        self.showStartsDatePicker = false
                                        self.showStartsTimePicker.toggle()
                                    }
                                }))
                        }
                    }

                    if showStartsDatePicker {
                        DatePicker("Start Date", selection: $startsDay, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .tint(.blue.opacity(0.3))
                    }

                    if showStartsTimePicker {
                        DatePicker("Start Date", selection: $startsDay, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .tint(.blue.opacity(0.3))
                    }
                }
                .clipped()

                VStack {
                    HStack {
                        Text("Ends")

                        Spacer()

                        Text(endsDay.formatted("d MMM yyyy"))
                            .frame(height: 34)
                            .padding(.horizontal, 12)
                            .background(Color.named("appLightGrey"))
                            .cornerRadius(17)
                            .systemFont(17, .regular, theme.main.accent)
                            .gesture(TapGesture().onEnded({
                                withAnimation(.easeInOut) {
                                    self.showStartsDatePicker = false
                                    self.showStartsTimePicker = false
                                    self.showEndsTimePicker = false
                                    self.showEndsDatePicker.toggle()
                                }
                            }))

                        if !isAllDay {
                            Text(endsDay.formatted("HH:mm"))
                                .frame(height: 34)
                                .padding(.horizontal, 12)
                                .background(Color.named("appLightGrey"))
                                .cornerRadius(17)
                                .systemFont(17, .regular, theme.main.accent)
                                .gesture(TapGesture().onEnded({
                                    withAnimation(.easeInOut) {
                                        self.showStartsDatePicker = false
                                        self.showStartsTimePicker = false
                                        self.showEndsDatePicker = false
                                        self.showEndsTimePicker.toggle()
                                    }
                                }))
                        }
                    }

                    if showEndsDatePicker {
                        DatePicker("End Date", selection: $endsDay, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.graphical)
                            .tint(.blue.opacity(0.3))
                    }

                    if showEndsTimePicker {
                        DatePicker("End Date", selection: $endsDay, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .tint(.blue.opacity(0.3))
                    }
                }
                .onChange(of: isAllDay) { _,_ in
                    self.showEndsDatePicker = false
                    self.showEndsTimePicker = false
                    self.showStartsTimePicker = false
                    self.showStartsDatePicker = false
                }
                .clipped()
            }
        }
    }
}
