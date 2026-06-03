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
    @Environment(\.calendarTheme) private var theme

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
                        .padding(12, 6)
                        .background(Color.named("appLightGrey"))
                        .clipShape(Capsule())
                        .systemFont(17, .regular, theme.main.accent)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                if type == .date {
                                    showDatePicker.toggle()
                                } else {
                                    showTimePicker.toggle()
                                }
                            }
                        }
                }
                
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
            .clipped()
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
                return date.dateFormat
            }
        } else {
            return date.timeFormat
        }
    }
}
