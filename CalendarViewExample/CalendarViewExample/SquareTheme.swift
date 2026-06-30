//
//  SquareTheme.swift
//  CalendarViewExample
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI
import CalendarView

extension Color {
    static let sqCream = Color(hex: "FFEED6")
    static let sqOlive = Color(hex: "A5AF79")
    static let sqBrown = Color(hex: "827148")
    static let sqPeach = Color(hex: "E8A07C")
    static let sqDark = Color(hex: "3D2E1A")
    static let sqCard = Color(hex: "FFF7ED")
}

extension CalendarTheme {
    static let square = CalendarTheme(
        main: .init(
            text: .sqDark,
            secondaryText: .sqBrown,
            tertiaryText: .sqBrown.opacity(0.6),
            accent: .sqOlive,
            accentLight: .sqOlive.opacity(0.3),
            background: .sqCream,
            separator: .sqBrown.opacity(0.25),
            cardBackground: .sqCard,
            fieldBackground: .sqBrown.opacity(0.15),
            switcherSelectedBackground: .sqOlive.opacity(0.3),
            draggingCapsule: .sqBrown.opacity(0.3),
            reminderBorder: .sqBrown.opacity(0.4),
            deleteText: .red
        ),
        header: .init(
            text: .sqDark,
            buttonBackground: .sqBrown.opacity(0.12),
            buttonBorder: .sqBrown.opacity(0.3)
        ),
        week: .init(
            text: .sqDark,
            todayText: .sqPeach,
            weekendText: .sqBrown,
            selectedText: .sqCard,
            todaySelectedText: .sqCard,
            selectedBackground: .sqOlive,
            todaySelectedBackground: .sqOlive
        ),
        day: .init(
            hourText: .sqBrown,
            eventText: .sqDark,
            background: .sqCream,
            separators: .sqBrown.opacity(0.2),
            todayLine: .sqPeach
        ),
        month: .init(
            dateText: .sqDark,
            todayText: .sqDark,
            eventText: .sqDark,
            plusMoreEventsText: .sqBrown,
            background: .sqCream,
            todayBackground: .sqPeach,
            separators: .sqBrown.opacity(0.25)
        ),
        year: .init(
            dateText: .sqDark,
            monthText: .sqBrown,
            todayText: .sqPeach,
            background: .sqCream
        ),
        button: .init(
            accent: .sqOlive,
            disabled: .sqBrown.opacity(0.3),
            background: .sqBrown.opacity(0.15)
        )
    )
}
