//
//  ContentView.swift
//  CalendarViewExample
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI
import CalendarView

struct ContentView: View {

    var body: some View {
        CalendarView()
            .headerBackground {
                GeometryReader { geo in
                    ZStack(alignment: .top) {
                        Image(.headerBG)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipShape(
                                RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight])
                            )
                    }
                }
            }
    }
}
