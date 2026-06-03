//
//  CalendarTheme.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 19.05.2025.
//

import SwiftUI

public struct CalendarTheme: Sendable {
    public let main: Main
    public let header: Header
    public let week: Week
    public let day: Day
    public let month: Month
    public let year: Year
    public let button: CalendarButtonTheme

    public init(
        main: Main = .init(),
        header: Header = .init(),
        week: Week = .init(),
        day: Day = .init(),
        month: Month = .init(),
        year: Year = .init(),
        button: CalendarButtonTheme = .init()
    ) {
        self.main = main
        self.header = header.resolved(using: main)
        self.week = week.resolved(using: main)
        self.day = day.resolved(using: main)
        self.month = month.resolved(using: main)
        self.year = year.resolved(using: main)
        self.button = button
    }

    public struct Main: Sendable {
        public let text: Color
        public let secondaryText: Color
        public let accent: Color
        public let background: Color

        public init(
            text: Color = .named("appBlack"),
            secondaryText: Color = .named("appGrey"),
            accent: Color = .named("AccentColor"),
            background: Color = .named("appLightBG")
        ) {
            self.text = text
            self.secondaryText = secondaryText
            self.accent = accent
            self.background = background
        }
    }

    public struct Header: Sendable {
        public var text: Color

        func resolved(using main: Main) -> Header {
            .init(
                text: text.resolve(main.background)
            )
        }

        public init(text: Color = .unset) {
            self.text = text
        }
    }

    public struct Week: Sendable {
        public var text: Color
        public var todayText: Color
        public var weekendText: Color
        public var selectedText: Color
        public var todaySelectedText: Color
        public var background: Color
        public var todayBackground: Color
        public var weekendBackground: Color
        public var selectedBackground: Color
        public var todaySelectedBackground: Color

        func resolved(using main: Main) -> Week {
            .init(
                text: text.resolve(main.background),
                todayText: todayText.resolve(main.accent),
                weekendText: todayText.resolve(main.background.opacity(0.5)),
                selectedText: selectedText.resolve(main.background),
                todaySelectedText: todaySelectedText.resolve(main.background),
                background: background.resolve(.clear),
                todayBackground: todayBackground.resolve(.clear),
                weekendBackground: todayBackground.resolve(.clear),
                selectedBackground: selectedBackground.resolve(main.accent),
                todaySelectedBackground: todaySelectedBackground.resolve(main.accent)
            )
        }

        public init(
            text: Color = .unset,
            todayText: Color = .unset,
            weekendText: Color = .unset,
            selectedText: Color = .unset,
            todaySelectedText: Color = .unset,
            background: Color = .unset,
            todayBackground: Color = .unset,
            weekendBackground: Color = .unset,
            selectedBackground: Color = .unset,
            todaySelectedBackground: Color = .unset
        ) {
            self.text = text
            self.todayText = todayText
            self.weekendText = weekendText
            self.selectedText = selectedText
            self.todaySelectedText = todaySelectedText
            self.background = background
            self.todayBackground = todayBackground
            self.weekendBackground = weekendBackground
            self.selectedBackground = selectedBackground
            self.todaySelectedBackground = todaySelectedBackground
        }
    }

    public struct Day: Sendable {
        public var hourText: Color
        public var eventText: Color
        public var background: Color
        public var separators: Color
        public var todayLine: Color

        func resolved(using main: Main) -> Day {
            .init(
                hourText: hourText.resolve(.named("appDarkGrey")),
                eventText: eventText.resolve(main.text),
                background: background.resolve(main.background),
                separators: separators.resolve(.named("appLightGrey")),
                todayLine: todayLine.resolve(.red)
            )
        }

        public init(
            hourText: Color = .unset,
            eventText: Color = .unset,
            background: Color = .unset,
            separators: Color = .unset,
            todayLine: Color = .unset
        ) {
            self.hourText = hourText
            self.eventText = eventText
            self.background = background
            self.separators = separators
            self.todayLine = todayLine
        }
    }

    public struct Month: Sendable {
        public var dateText: Color
        public var todayText: Color
        public var eventText: Color
        public var plusMoreEventsText: Color
        public var background: Color
        public var todayBackground: Color
        public var separators: Color

        func resolved(using main: Main) -> Month {
            .init(
                dateText: dateText.resolve(main.text),
                todayText: todayText.resolve(main.background),
                eventText: eventText.resolve(main.text),
                plusMoreEventsText: plusMoreEventsText.resolve(main.secondaryText),
                background: background.resolve(main.background),
                todayBackground: todayBackground.resolve(main.accent),
                separators: separators.resolve(.named("appLightGrey"))
            )
        }

        public init(
            dateText: Color = .unset,
            todayText: Color = .unset,
            eventText: Color = .unset,
            plusMoreEventsText: Color = .unset,
            background: Color = .unset,
            todayBackground: Color = .unset,
            separators: Color = .unset
        ) {
            self.dateText = dateText
            self.todayText = todayText
            self.eventText = eventText
            self.plusMoreEventsText = plusMoreEventsText
            self.background = background
            self.todayBackground = todayBackground
            self.separators = separators
        }
    }

    public struct Year: Sendable {
        public var dateText: Color
        public var monthText: Color
        public var todayText: Color
        public var background: Color

        func resolved(using main: Main) -> Year {
            .init(
                dateText: dateText.resolve(main.text),
                monthText: monthText.resolve(main.text),
                todayText: todayText.resolve(main.accent),
                background: background.resolve(main.background)
            )
        }

        public init(
            dateText: Color = .unset,
            monthText: Color = .unset,
            todayText: Color = .unset,
            background: Color = .unset
        ) {
            self.dateText = dateText
            self.monthText = monthText
            self.todayText = todayText
            self.background = background
        }
    }

    public struct CalendarButtonTheme: Sendable {
        public var accent: Color
        public var disabled: Color
        public var background: Color

        public init(
            accent: Color = .named("AccentColor"),
            disabled: Color = .named("appLightGrey"),
            background: Color = .named("appLightGrey")
        ) {
            self.accent = accent
            self.disabled = disabled
            self.background = background
        }
    }
}

public extension Color {
    static func named(_ name: String) -> Color {
        Color(name, bundle: .module)
    }
}

public extension Color {
    static let unset = Color.clear

    var isUnset: Bool {
        self == .unset
    }

    func resolve(_ fallback: Color) -> Color {
        isUnset ? fallback : self
    }
}
