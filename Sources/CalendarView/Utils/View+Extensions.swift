//
//  View+Extensions.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 15.04.2025.
//

import SwiftUI

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

    @ViewBuilder
    func applyIfLet<T>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let v = value {
            transform(self, v)
        } else {
            self
        }
    }
}

extension View {
    func systemFont(_ size: CGFloat, _ weight: Font.Weight = .regular, _ color: Color = .black) -> some View {
        self.font(.system(size: size, weight: weight))
            .foregroundStyle(color)
    }

    func systemFont(_ size: CGFloat, _ weight: Font.Weight = .regular, _ colorResource: ColorResource, _ opacity: Double = 1) -> some View {
        self.font(.system(size: size, weight: weight))
            .foregroundStyle(Color(colorResource).opacity(opacity))
    }

    func systemFont(_ size: CGFloat, _ color: Color = .black) -> some View {
        self.font(.system(size: size))
            .foregroundStyle(color)
    }

    func systemFont(_ size: CGFloat, _ colorResource: ColorResource, _ opacity: Double = 1) -> some View {
        self.font(.system(size: size))
            .foregroundStyle(Color(colorResource).opacity(opacity))
    }
}

public extension ToolbarContent {
    @ToolbarContentBuilder
    func removeSharedBackground() -> some ToolbarContent {
        Group {
            if #available(iOS 26, *) {
                self.sharedBackgroundVisibility(.hidden)
            } else {
                self
            }
        }
    }
}
