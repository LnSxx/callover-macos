//
//  StatCard.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)

            Text(value)
                .font(.largeTitle)
                .bold()

            Text(title)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: 180, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    StatCard(
        title: "Missed calls", value: "67", icon: "phone.down"
    )
}
