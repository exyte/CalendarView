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

    @ViewBuilder
    func applyIfLet<T>(_ value: T?, transform: (Self, T) -> some View) -> some View {
        if let v = value {
            transform(self, v)
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

extension RoundedRectangle {
    static func styled(_ cornerRadius: CGFloat, _ color: Color) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundStyle(color)
    }
}

extension Image {
    func recolor(_ color: Color) -> some View {
        self.renderingMode(.template).foregroundStyle(color)
    }
}

extension View {
    func systemFont(_ size: CGFloat, _ weight: Font.Weight = .regular, _ color: Color = .black) -> some View {
        self.font(.system(size: size, weight: weight))
            .foregroundStyle(color)
    }

    func systemFont(_ size: CGFloat, _ color: Color = .black) -> some View {
        self.font(.system(size: size))
            .foregroundStyle(color)
    }
}

extension Color {
    /// Simulates the result of applying `self.opacity(opacity)` over `background`, returning a fully opaque color.
    func blended(opacity: Double) -> Color {
        // Extract RGB components (SwiftUI doesn't support this directly, so we go via UIColor)
        let fg = UIColor(self).cgColor.components ?? [0,0,0,1]
        let bg = UIColor(.white).cgColor.components ?? [0,0,0,1]

        let r = fg[0] * opacity + bg[0] * (1 - opacity)
        let g = fg[1] * opacity + bg[1] * (1 - opacity)
        let b = fg[2] * opacity + bg[2] * (1 - opacity)

        return Color(red: r, green: g, blue: b)
    }
}

@propertyWrapper
public struct BindableValue<Value: Sendable>: DynamicProperty, Sendable {
    @State private var internalValue: Value
    private var externalBinding: Binding<Value>?

    public var wrappedValue: Value {
        get { externalBinding?.wrappedValue ?? internalValue }
        nonmutating set {
            if let _ = externalBinding {
                externalBinding?.wrappedValue = newValue
            } else {
                internalValue = newValue
            }
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
    }

    public init(wrappedValue: Value) {
        _internalValue = State(wrappedValue: wrappedValue)
        externalBinding = nil
    }

    public mutating func bind(_ binding: Binding<Value>) {
        self.externalBinding = binding
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int {
        self
    }
}
