//
//  ContactStatusBadge.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactStatusBadge: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .foregroundStyle(color)
    }
}

#Preview {
    ContactStatusBadge(
        title: "BLOCKED",
        systemImage: "nosign",
        color: .red,
    )
}
