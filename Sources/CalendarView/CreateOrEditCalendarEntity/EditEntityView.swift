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

    var body: some View {
        VStack {
            CreateOrEditEntityHeaderView(title: "Edit") {
                await shouldSave(entity)
            }

            EditEntityFieldsView(entity: $entity)
        }
    }
}
