//
//  EditEntityView.swift
//  CalendarView
//
//  Created by Exyte on 03.06.2026.
//

import SwiftUI

struct EditEntityView<Entity: CalendarEntity>: View {

    @State var entity: Entity

    var shouldSave: (Entity) async -> ()

    var saveEnabled: Bool {
        !entity.title.isEmpty && !entity.calendarID.isEmpty
    }

    var body: some View {
        VStack {
            CloseSaveHeaderView(title: "Edit", showDraggingCapsule: false, saveButtonEnabled: saveEnabled) {
                await shouldSave(entity)
            }

            EditEntityFieldsView(entity: $entity)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
