//
//  CalendarEntityProtocol.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 30.05.2025.
//

import SwiftUI

public enum EntityType: Sendable {
    case event, reminder
}

public protocol CalendarEntity: Identifiable, Sendable {
    var id: String { get }
    var calendarID: String { get }

    var title: String { get }
    var notes: String? { get }
    var calendarColor: Color { get }
    var startDate: Date { get }

    var isLocal: Bool { get }
    var entityType: EntityType { get }
}

extension CalendarEntity {
    public var isLocal: Bool {
        calendarID == "local"
    }
}

