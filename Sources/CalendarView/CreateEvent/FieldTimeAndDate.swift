//
//  TimeAndDateView.swift
//  Jaye
//
//  Created by Exyte on 01.04.2025.
//

import SwiftUI

struct FieldTimeAndDate: View {
    @Binding var isAllDay: Bool
    @Binding var startsDay: Date
    @Binding var endsDay: Date
    
    @State private var showStartsDatePicker: Bool = false
    @State private var showStartsTimePicker: Bool = false
    @State private var showEndsDatePicker: Bool = false
    @State private var showEndsTimePicker: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            
            //Image(.bigClock)

            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text("Time and Date")
                        //.sfProText(.regular, 17)

                    Spacer()
                    
                    Text("All day")
                        //.sfProText(.regular, 17)

                    Toggle("", isOn: $isAllDay)
                        .labelsHidden()
                        //.toggleStyle(CustomToggleStyle())
                }
                
                HStack {
                    Text("Starts")
                        //.sfProText(.regular, 17)

                    Spacer()
                    
                    Text(startsDay.formatted("d MMM yyyy"))
                        //.sfProText(.regular, 17, .cadet)
                        .padding(12, 8)
                        //.background(.azureishWhite)
                        .cornerRadius(6)
                        .gesture(TapGesture().onEnded({
                            self.showEndsDatePicker = false
                            self.showEndsTimePicker = false
                            self.showStartsTimePicker = false
                            self.showStartsDatePicker.toggle()
                        }))
                    
                    if !isAllDay {
                        Text(startsDay.formatted("HH:mm"))
                            //.sfProText(.regular, 17, .cadet)
                            .padding(12, 8)
                            //.background(.azureishWhite)
                            .cornerRadius(6)
                            .gesture(TapGesture().onEnded({
                                self.showEndsDatePicker = false
                                self.showEndsTimePicker = false
                                self.showStartsDatePicker = false
                                self.showStartsTimePicker.toggle()
                            }))
                    }
                }
                
                if showStartsDatePicker {
                    DatePicker("Start Date", selection: $startsDay, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.graphical)
                        //.tint(.policeBlue)
                }
                
                if showStartsTimePicker {
                    DatePicker("Start Date", selection: $startsDay, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        //.tint(.policeBlue)
                }
                
                HStack {
                    Text("Ends")
                        //.sfProText(.regular, 17)

                    Spacer()
                    
                    Text(endsDay.formatted("d MMM yyyy"))
                        //.sfProText(.regular, 17, .cadet)
                        .padding(12, 8)
                        //.background(.azureishWhite)
                        .cornerRadius(6)
                        .gesture(TapGesture().onEnded({
                            self.showStartsDatePicker = false
                            self.showStartsTimePicker = false
                            self.showEndsTimePicker = false
                            self.showEndsDatePicker.toggle()
                        }))
                    
                    if !isAllDay {
                        Text(endsDay.formatted("HH:mm"))
                            //.sfProText(.regular, 17, .cadet)
                            .padding(12, 8)
                            //.background(.azureishWhite)
                            .cornerRadius(6)
                            .gesture(TapGesture().onEnded({
                                self.showStartsDatePicker = false
                                self.showStartsTimePicker = false
                                self.showEndsDatePicker = false
                                self.showEndsTimePicker.toggle()
                            }))
                    }
                }
                
                if showEndsDatePicker {
                    DatePicker("End Date", selection: $endsDay, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.graphical)
                        //.tint(.policeBlue)
                }
                
                if showEndsTimePicker {
                    DatePicker("End Date", selection: $endsDay, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        //.tint(.policeBlue)
                }
            }
            .onChange(of: isAllDay) { _,_ in
                self.showEndsDatePicker = false
                self.showEndsTimePicker = false
                self.showStartsTimePicker = false
                self.showStartsDatePicker = false
            }
        }
    }
}
