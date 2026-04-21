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
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack {
                    Text(type.rawValue)

                    Spacer()
                    
                    Text(getCurrentDateStringValue())
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
                        .tint(.blue.opacity(0.3))
                }
                
                if showTimePicker {
                    DatePicker("Start Date", selection: $date, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .tint(.blue.opacity(0.3))
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
