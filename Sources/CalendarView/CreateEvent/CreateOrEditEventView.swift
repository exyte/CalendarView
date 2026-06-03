//
//  CreateOrEditEventView.swift
//  CalendarView
//
//  Created by Exyte on 03.06.2026.
//

import SwiftUI

struct CreateOrEditEventView<Entity: CalendarEntity>: View {
    @Environment(\.calendarTheme) private var theme
    @EnvironmentObject var viewModel: CalendarViewModel

    var entity: Binding<Entity>?
    var didEditEntity: (()->())?

    var body: some View {
        NavigationStack {
            VStack {
                if let entity {
                    CreateOrEditEventHeaderView(title: "New") {
                        didEditEntity?()
                    }

                    EditCalendarEntityView(entity: entity)
                } else {
                    CreateEventView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        }
        .background(theme.main.background)
    }
}

extension CreateOrEditEventView where Entity == CalendarEvent {
    init() {
        self.init(entity: nil)
    }
}
