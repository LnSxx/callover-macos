//
//  ContactStatus.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactStatus: View {
    private let isFavourite: Bool
    private let isMuted: Bool
    private let isBlocked: Bool
    
    init(isFavourite: Bool, isMuted: Bool, isBlocked: Bool) {
        self.isFavourite = isFavourite
        self.isMuted = isMuted
        self.isBlocked = isBlocked
    }
    
    var body: some View {
        HStack(spacing: 5) {
            if isFavourite {
                ContactStatusBadge(
                    title: "FAVOURITE",
                    systemImage: "star.fill",
                    color: .yellow,
                )
            }
            
            if isMuted {
                ContactStatusBadge(
                    title: "MUTED",
                    systemImage: "bell.slash.fill",
                    color: .secondary,
                )
            }
            
            if isBlocked {
                ContactStatusBadge(
                    title: "BLOCKED",
                    systemImage: "nosign",
                    color: .red,
                )
            }
        }
    }
}

#Preview {
    ContactStatus(
        isFavourite: true, isMuted: true, isBlocked: true
    )
}
