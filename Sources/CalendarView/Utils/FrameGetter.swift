//
//  FrameGetter.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 21.05.2025.
//

import SwiftUI

struct FrameGetter: ViewModifier {
    @Binding var frame: CGRect

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    DispatchQueue.main.async {
                        let rect = proxy.frame(in: .global)
                        // This avoids an infinite layout loop
                        if rect.integral != self.frame.integral {
                            self.frame = rect
                        }
                    }
                    return AnyView(EmptyView())
                }
            )
    }
}

struct SizeGetter: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    if proxy.size != self.size {
                        DispatchQueue.main.async {
                            self.size = proxy.size
                        }
                    }
                    return Color.clear
                }
            )
    }
}

extension View {

    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }

    func sizeGetter(_ size: Binding<CGSize>) -> some View {
        modifier(SizeGetter(size: size))
    }
}

struct MaxHeightGetter: ViewModifier {
    @Binding var maxHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: MaxHeightPreferenceKey.self, value: proxy.size.height)
                }
            )
            .onPreferenceChange(MaxHeightPreferenceKey.self) { newMax in
                DispatchQueue.main.async {
                    if maxHeight != newMax {
                        maxHeight = newMax
                    }
                }
            }
    }
}

private struct MaxHeightPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

extension View {
    func maxHeightGetter(_ binding: Binding<CGFloat>) -> some View {
        modifier(MaxHeightGetter(maxHeight: binding))
    }
}

struct MeasuringTrickView<Content: View>: View {
    @Binding var size: CGSize?
    let content: () -> Content

    var body: some View {
        content()
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            // Only assign once
                            if size == nil {
                                size = geo.size
                            }
                        }
                }
            )
            .hidden() // Completely exclude from layout and drawing
    }
}
