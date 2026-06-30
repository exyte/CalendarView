//
//  LibraryFontModifier.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 30.06.2026.
//

import SwiftUI

private struct LibraryFontModifier: ViewModifier {
    @Environment(\.calendarCustomizationParams) var params
    @ScaledMetric var scaledSize: CGFloat

    var size: CGFloat
    var weight: Font.Weight
    var color: Color

    init(size: CGFloat, weight: Font.Weight, color: Color) {
        self._scaledSize = ScaledMetric(wrappedValue: size)
        self.size = size
        self.weight = weight
        self.color = color
    }

    func body(content: Content) -> some View {
        let effectiveSize = params.useDynamicType ? scaledSize : size
        let font: Font = {
            if let name = params.customFontName {
                return .custom(name, fixedSize: effectiveSize)
            }
            return .system(size: effectiveSize)
        }()

        content
            .font(font)
            .fontWeight(weight)
            .foregroundStyle(color)
    }
}

extension View {
    func libraryFont(_ size: CGFloat, _ weight: Font.Weight = .regular, _ color: Color = .black) -> some View {
        modifier(LibraryFontModifier(size: size, weight: weight, color: color))
    }

    func libraryFont(_ size: CGFloat, _ weight: Font.Weight = .regular, _ colorResource: ColorResource, _ opacity: Double = 1) -> some View {
        modifier(LibraryFontModifier(size: size, weight: weight, color: Color(colorResource).opacity(opacity)))
    }

    func libraryFont(_ size: CGFloat, _ color: Color = .black) -> some View {
        modifier(LibraryFontModifier(size: size, weight: .regular, color: color))
    }

    func libraryFont(_ size: CGFloat, _ colorResource: ColorResource, _ opacity: Double = 1) -> some View {
        modifier(LibraryFontModifier(size: size, weight: .regular, color: Color(colorResource).opacity(opacity)))
    }
}
