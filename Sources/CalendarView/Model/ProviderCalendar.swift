//
//  ProviderCalendar.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 29.05.2025.
//

import SwiftUI

public struct ProviderCalendar: Identifiable, Equatable, Sendable, Codable {
    static let defaultSource = "library"

    public let id: String
    var title: String
    var source: String
    var color: Color

    init(id: String = UUID().uuidString, title: String = "", source: String = defaultSource, color: Color = .gray) {
        self.id = id
        self.title = title
        self.source = source
        self.color = color
    }
}

struct DateInterval: Hashable {
    var start: Date
    var end: Date
}
