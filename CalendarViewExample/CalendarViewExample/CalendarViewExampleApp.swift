//
//  CalendarViewExampleApp.swift
//  CalendarViewExample
//
//  Created by Alisa Mylnikova on 14.04.2025.
//

import SwiftUI

@main
struct CalendarViewExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                List {
                    Section {
                        NavigationLink("Simple Calendar") {
                            SimpleCalendar()
                                .toolbar(.hidden, for: .navigationBar)
                        }

                        NavigationLink("Custom Calendar") {
                            CustomCalendar()
                                .toolbar(.hidden, for: .navigationBar)
                        }
                    }
                }
            }
        }
    }
}
