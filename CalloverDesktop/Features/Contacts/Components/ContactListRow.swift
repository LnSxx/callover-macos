//
//  ContactListRow.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactListRow: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 12) {
            ContactAvatar(
                initial: contact.initials,
                variant: .small,
            )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(contact.displayName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if contact.isFavourite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                    
                    if contact.isMuted {
                        Image(systemName: "bell.slash.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    if contact.isBlocked {
                        Image(systemName: "nosign")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    let contact = Contact(
        id: "id",
        ownerId: "owner-id",
        contactUserId: "contact-user-id",
        alias: "My best friend",
        note: "Some note",
        isFavourite: true,
        isBlocked: true,
        isMuted: true,
        createdAt: Date(),
        updatedAt: Date(),
    )
    ContactListRow(contact: contact)
}
