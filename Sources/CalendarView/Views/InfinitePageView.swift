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
    @State private var offset: CGFloat = .zero
    
    @Binding var didEndAnimation: Int
    @Binding var isDragging: Bool

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
    
    var body: some View {
        ZStack {
            content(pageIndex(currentPage + 2) - 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: CGFloat(1 - offsetIndex(currentPage - 1)) * width)

            content(pageIndex(currentPage + 1) + 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: CGFloat(1 - offsetIndex(currentPage + 1)) * width)

            content(pageIndex(currentPage + 0) + 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(x: CGFloat(1 - offsetIndex(currentPage)) * width)
        }
        .contentShape(Rectangle())
        .offset(x: translation)
        .offset(x: offset)
        .gesture(dragGesture)
        .clipped()
    }
    
    private func pageIndex(_ x: Int) -> Int {
        // 0 0 0 3 3 3 6 6 6 ...
        Int((CGFloat(x) / 3).rounded(.down)) * 3
    }
    
    
    private func offsetIndex(_ x: Int) -> Int {
        // 0 1 2 0 1 2 0 1 2 ...
        if x >= 0 {
            return x % 3
        } else {
            return (x + 1) % 3 + 2
        }
    }
}
