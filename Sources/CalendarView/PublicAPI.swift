//
//  PublicAPI.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 30.04.2025.
//

import SwiftUI

extension CalendarView {

    /// trigger for updates
    public func idForUpdate(_ idForUpdate: UUID) -> CalendarView {
        var copy = self
        copy.idForUpdate = idForUpdate
        return copy
    }

    /// how many hours will fit vertically in a day displayMode, default is 12
    public func hoursToFit(_ hoursToFit: CGFloat) -> CalendarView {
        if hoursToFit > 24 {
            print("Please specify hoursToFit's value less or equal to 24")
            return self
        }
        self.customizationParams.hoursToFit = hoursToFit
        return self
    }

    /// default is "h a"
    public func hourLabelFormat(_ hourLabelFormat: String) -> CalendarView {
        self.customizationParams.hourLabelFormat = hourLabelFormat
        return self
    }

    /// what day to start the week from, 1 - Sunday, 2 - Monday
    public func firstDayOfWeek(_ firstDayOfWeek: Int) -> CalendarView {
        self.customizationParams.firstDayOfWeek = firstDayOfWeek
        return self
    }

    /// Background for header and week picker
    public func headerBackground(_ background: HeaderBackground) -> CalendarView {
        self.customizationParams.headerBackground = background
        return self
    }

    public func headerBackground<Content: View>(viewBuilder: @escaping () -> Content) -> CalendarView {
        self.customizationParams.headerBackground = HeaderBackground(viewBuilder: viewBuilder)
        return self
    }
    
    public func eventDetailsClosure(_ closure: @escaping (any CalendarEntity)->()) -> CalendarView {
        self.customizationParams.eventDetailsClosure = closure
        return self
    }
    
    public func isDayInWeekSwitcherPagingEnabled(_ value: Bool) -> CalendarView {
        self.customizationParams.isDayInWeekSwitcherPagingEnabled = value
        return self
    }
}
