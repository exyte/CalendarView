//
//  Utils.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 15.04.2025.
//

import SwiftUI

extension Array {
    mutating func sort<T: Comparable>(by keyPath: KeyPath<Element, T>) {
        self.sort { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
    }
}

extension Array {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        self.sorted { $0[keyPath: keyPath] > $1[keyPath: keyPath] }
    }
}

extension View {
    func greedyWidth() -> some View {
        self.frame(maxWidth: .infinity)
    }

    func padding(_ horizontal: CGFloat, _ vertical: CGFloat) -> some View {
        self.padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
    }

    func size(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    func fullTap(action: @escaping () -> Void) -> some View {
        self.contentShape(Rectangle())
            .onTapGesture {
                action()
            }
    }

    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }

    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}

extension Shape {
    func styled(_ foregroundColor: Color, border borderColor: Color = .clear, _ borderWidth: CGFloat = 0) -> some View {
        self.foregroundStyle(foregroundColor)
            .overlay(
                self
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

func styledRoundedRectangle(_ cornerRadius: CGFloat, _ color: Color) -> some View {
    RoundedRectangle(cornerRadius: cornerRadius)
        .foregroundStyle(color)
}

extension View {
    func roundedRectangleBackground(_ horPadding: CGFloat, _ verPadding: CGFloat, cornerRadius: CGFloat, _ color: Color) -> some View {
        self.padding(horPadding, verPadding)
            .background(RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(color)
            )
    }
}

extension Image {
    func recolor(_ color: Color) -> some View {
        self.renderingMode(.template).foregroundStyle(color)
    }
}
