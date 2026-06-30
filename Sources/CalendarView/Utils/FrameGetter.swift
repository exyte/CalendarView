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
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { update(proxy.frame(in: .global)) }
                        .onChange(of: proxy.frame(in: .global)) { _, newValue in update(newValue) }
                }
            )
    }

    private func update(_ newValue: CGRect) {
        // This avoids an infinite layout loop
        if newValue.integral != frame.integral {
            frame = newValue
        }
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
                            if (size == nil || size == .zero) && geo.size != .zero {
                                size = geo.size
                            }
                        }
                        .onChange(of: geo.size) { _, newSize in
                            if newSize != .zero {
                                size = newSize
                            }
                        }
                }
            )
            .hidden() // exclude from drawing
    }
}

struct FinalMeasuringTrickView<Content: View>: View {
    @Binding var size: CGSize?
    @State private var rawSize: CGSize = .zero
    var id: String?

    let content: () -> Content

    var body: some View {
        content()
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            if let id {
                                print("measuring", id, rawSize, geo.size)
                            }
                            if geo.size.height != 0 {
                                rawSize = geo.size
                            }
                        }
                        .onChange(of: geo.size) { _ , newSize in
                            if let id {
                                print("measuring", id, rawSize, newSize)
                            }
                            if newSize.height != 0 {
                                rawSize = newSize
                            }
                        }
                }
            )
            .onChange(of: rawSize) { _ , newValue in
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(16)) // 1 frame
                    if let id {
                        print("measuring", id, "rawSize change", rawSize, newValue)
                    }
                    if rawSize == newValue {
                        size = newValue
                    }
                }
            }
            .hidden()
    }
}
