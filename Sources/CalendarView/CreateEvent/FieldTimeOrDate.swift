//
//  TimeOrDateView.swift
//  Jaye
//
//  Created by Exyte on 03.04.2025.
//

import SwiftUI

enum TimeOrDateViewType: String, CaseIterable {
    case time = "Time"
    case date = "Date"
}

struct FieldTimeOrDate: View {
    @State var type: TimeOrDateViewType = .date
    
    @Binding var date: Date
    
    @State private var showDatePicker: Bool = false
    @State private var showTimePicker: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            
//            Image(type == .date ? .calendar : .bigClock)
//                .renderingMode(.template)
//                .foregroundColor(.cadetGrey)
//                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text(type.rawValue)
                       // .sfProText(.regular, 17)

                    Spacer()
                    
                    Text(getCurrentDateStringValue())
                        //.sfProText(.regular, 17, .cadet)
                }
                .gesture(
                    TapGesture()
                        .onEnded {
                            if type == .date {
                                showDatePicker.toggle()
                            } else {
                                showTimePicker.toggle()
                            }
                        }
                )
                
                if showDatePicker {
                    DatePicker("Start Date", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.graphical)
                        //.tint(.policeBlue)
                }
                
                if showTimePicker {
                    DatePicker("Start Date", selection: $date, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        //.tint(.policeBlue)
                }
            }
        }
    }
    
    func getCurrentDateStringValue() -> String {
        if type == .date {
            if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInTomorrow(date) {
                return "Tomorrow"
            } else {
                return date.formatted("d MMM yyyy")
            }
        } else {
            return date.formatted("HH:mm")
        }
    }
}
