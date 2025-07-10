//
//  PopupHeaderView.swift
//  Jaye
//
//  Created by Exyte on 08.04.2025.
//

import SwiftUI

struct PopupHeaderView: View {
    var body: some View {
        VStack {
            Color.gray
                .frame(width: 24, height: 2)
                .cornerRadius(1)
        }
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(
            .rect(
                topLeadingRadius: 32,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 32
            )
        )
        .offset(y: 4    )
        .shadow(
            color: .black,
            radius: 15,
            x: 0, y: 23
        )
    }
}
