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
                Text(params.selectedDate.wrappedValue.formatted("d MMMM yyyy"))
                    .systemFont(15, .regular, theme.week.text)
                    .lineLimit(1)
                
                if  params.selectedDate.wrappedValue.startOfDay == today {
                    Text("(Today)")
                        .systemFont(15, .semibold, theme.week.text)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundStyle(theme.week.text)
                
                Text("\(viewModel.events.count) Events")
                    .systemFont(15, .regular, theme.week.text)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
        }
    }
}
