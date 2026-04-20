//
//  DefaultWeekSwitcherDayFooterView.swift
//  CalendarView
//
//  Created by Exyte on 25.08.2025.
//

import SwiftUI

public struct DefaultWeekSwitcherDayFooterView: View {
    @Environment(\.calendarTheme) private var theme
    @EnvironmentObject var viewModel: CalendarViewModel

    var params: weekSwitcherDayFooterParams

    public init(params: weekSwitcherDayFooterParams) {
        self.params = params
    }
    
    let today = Date().startOfDay

    public var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(params.date.formatted("d MMMM yyyy"))
                    .systemFont(15, .regular, theme.main.text)
                    .lineLimit(1)
                
                if  params.date.startOfDay == today {
                    Text("(Today)")
                        .systemFont(15, .semibold, theme.main.text)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(theme.main.accent)
                
                Text("\(viewModel.getEventsAndRemindersCount(from: params.date, displayMode: CalendarDisplayMode.init(rawValue: params.daysCount) ?? .day, fullscreenDate: params.date)) Events")
                    .systemFont(15, .regular, theme.main.accent)
                    .lineLimit(1)
            }
            .padding(16)
        }
    }
}
