//
//  ProviderCalendar.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.05.2025.
//

import SwiftUI

struct ProviderCalendar: Identifiable, Sendable {
    let id: String
    let title: String
    let source: String
    let color: Color
}

struct DateInterval {
    var start: Date
    var end: Date
}
