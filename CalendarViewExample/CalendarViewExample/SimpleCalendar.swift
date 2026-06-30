//
//  SimpleCalendar.swift
//  CalendarViewExample
//
//  Created by Alisa Mylnikova on 30.06.2026.
//

import SwiftUI
import CalendarView

struct SimpleCalendar: View {
    var body: some View {
        CalendarView()
            //.customFont("Georgia")
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
            .ignoresSafeArea(edges: .bottom)
    }
}
