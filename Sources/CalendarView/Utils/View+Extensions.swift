//
//  View+Extensions.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 15.04.2025.
//

import SwiftUI
import UIKit

// CalendarView is typically pushed below a NavigationView/NavigationStack, which already
// consumes/reports the top safe area as zero to anything nested inside it, regardless of the
// device's real value - so that can't be used to detect devices with a genuinely zero top safe
// area (e.g. the iPhone Duo foldable, whose status bar sits beside a camera island rather than
// across the top edge). Reading the real window directly works reliably instead.
@MainActor
public func calendarMinimumTopSafeAreaPadding(_ minimum: CGFloat = 8) -> CGFloat {
    let realTopInset = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.windows.first(where: \.isKeyWindow) }
        .first?.safeAreaInsets.top ?? 0
    return realTopInset == 0 ? minimum : 0
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

    @ViewBuilder
    func applyIfLet<T>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let v = value {
            transform(self, v)
        } else {
            self
        }
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
