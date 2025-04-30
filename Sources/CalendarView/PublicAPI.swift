//
//  PublicAPI.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 30.04.2025.
//

import SwiftUI

extension CalendarView {

//    public func selectedDate(_ selectedDate: Binding<Date>) -> CalendarView {
//        var calendar = self
//        calendar._selectedDate = selectedDate
//        return calendar
//    }

    public func hoursToFit(_ hoursToFit: Int) -> CalendarView {
        if hoursToFit > 24 {
            print("Please specify hoursToFit's value less or equal to 24")
            return self
        }
        var calendar = self
        calendar.hoursToFit = hoursToFit
        return calendar
    }
}
