//
//  PublicAPI.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 30.04.2025.
//

import SwiftUI
import UIKit

extension CalendarView {

    /// trigger for updates
    public func idForUpdate(_ idForUpdate: UUID) -> CalendarView {
        var copy = self
        copy.idForUpdate = idForUpdate
        return copy
    }

    /// how many hours will fit vertically in a day displayMode, default is 12
    public func hoursToFit(_ hoursToFit: CGFloat) -> CalendarView {
        var copy = self
        copy.customizationParams.hoursToFit = min(24, max(1, hoursToFit))
        return copy
    }

    /// default is "h a"
    public func hourLabelFormat(_ hourLabelFormat: String) -> CalendarView {
        var copy = self
        copy.customizationParams.hourLabelFormat = hourLabelFormat
        return copy
    }

    /// what day to start the week from, 1 - Sunday, 2 - Monday
    public func firstDayOfWeek(_ firstDayOfWeek: Int) -> CalendarView {
        var copy = self
        copy.customizationParams.firstDayOfWeek = firstDayOfWeek
        return copy
    }

    /// Background for header and week picker
    public func headerBackground(_ background: HeaderBackground) -> CalendarView {
        var copy = self
        copy.customizationParams.headerBackground = background
        return copy
    }

    public func headerBackground<Content: View>(viewBuilder: @escaping () -> Content) -> CalendarView {
        var copy = self
        copy.customizationParams.headerBackground = HeaderBackground(viewBuilder: viewBuilder)
        return copy
    }

    public func eventDetailsClosure(_ closure: @escaping (any CalendarEntity)->()) -> CalendarView {
        var copy = self
        copy.customizationParams.eventDetailsClosure = closure
        return copy
    }

    public func isDayInWeekSwitcherPagingEnabled(_ value: Bool) -> CalendarView {
        var copy = self
        copy.customizationParams.isDayInWeekSwitcherPagingEnabled = value
        return copy
    }

    /// Use a custom font family by name. Font sizes and colors defined in the library are preserved.
    public func customFont(_ name: String) -> CalendarView {
        var copy = self
        copy.customizationParams.customFontName = name
        return copy
    }

    /// Scale all fonts with the system-wide Dynamic Type accessibility setting.
    public func useDynamicType(_ enabled: Bool) -> CalendarView {
        var copy = self
        copy.customizationParams.useDynamicType = enabled
        return copy
    }
}
