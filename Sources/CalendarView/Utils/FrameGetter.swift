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

//struct SizeGetter: ViewModifier {
//    @Binding var size: CGSize
//
//    func body(content: Content) -> some View {
//        content
//            .background(
//                GeometryReader { proxy -> Color in
//                    if proxy.size != self.size {
//                        DispatchQueue.main.async {
//                            self.size = proxy.size
//                        }
//                    }
//                    return Color.clear
//                }
//            )
//    }
//}

extension View {

    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }

    func sizeGetter(_ size: Binding<CGSize>) -> some View {
        modifier(SizeGetter(size: size))
    }
}

struct SizeGetter: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { newSize in
                if size != newSize {
                    size = newSize
                }
            }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
