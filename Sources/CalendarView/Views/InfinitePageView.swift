//
//  InfinitePageView.swift
//  CalendarView
//
//  Created by Exyte on 02.09.2025.
//

import SwiftUI

struct InfiniteTabPageView<Content: View>: View {
    @GestureState private var translation: CGFloat = .zero
    @Binding var currentPage: Int
    @Binding var didEndAnimation: Int
    @Binding var isDragging: Bool
    
    @State private var offset: CGFloat = .zero

    private let width: CGFloat
    private let animationDuration: CGFloat = 0.25
    let content: (_ page: Int) -> Content
    
    init(width: CGFloat = 390, currentPage: Binding<Int>, didEndAnimation: Binding<Int>, isDragging: Binding<Bool>, @ViewBuilder content: @escaping (_ page: Int) -> Content) {
        self.width = width
        self.content = content
        self._currentPage = currentPage
        self._didEndAnimation = didEndAnimation
        self._isDragging = isDragging
    }
    
    var body: some View {
        ZStack {
            pageView(index: -1)
            pageView(index: 0)
            pageView(index: 1)
        }
        .offset(x: translation + offset)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .clipped()
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .updating($translation) { value, state, _ in
                isDragging = true
                let translation = min(width, max(-width, value.translation.width))
                state = translation
            }
            .onEnded { value in
                offset = min(width, max(-width, value.translation.width))
                let predictEndOffset = value.predictedEndTranslation.width
                withAnimation(.easeOut(duration: animationDuration)) {
                    if offset < -width / 2 || predictEndOffset < -width {
                        offset = -width
                    } else if offset > width / 2 || predictEndOffset > width {
                        offset = width
                    } else {
                        offset = 0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    if offset < 0 {
                        currentPage += 1
                        didEndAnimation = 1
                    } else if offset > 0 {
                        currentPage -= 1
                        didEndAnimation = -1
                    }
                    offset = 0
                    isDragging = false
                }
            }
    }

    private func pageView(index: Int) -> some View {
        var offset: Int {
            if index == -1 { -1 }
            else if index == 0 { 1 }
            else { 0 }
        }

        return content(pageIndex(currentPage + (1 - index)) + index)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(x: CGFloat(1 - offsetIndex(currentPage + offset)) * width)
    }

    private func pageIndex(_ x: Int) -> Int {
        // Used to determine on which page each of the 3 content elements should be displayed.
        Int((CGFloat(x) / 3).rounded(.down)) * 3
    }

    private func offsetIndex(_ x: Int) -> Int {
        // Used to determine the order of the three contents in a static state.
        if x >= 0 {
            return x % 3
        } else {
            return (x % 3 + 3) % 3
        }
    }
}
