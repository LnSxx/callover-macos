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
            avatar
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(displayName)
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
                        Image(systemName: "hand.raised.fill")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
    
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
            
            Text(initials)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(width: 34, height: 34)
    }
    
    private var displayName: String {
        let alias = contact.alias?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let alias, !alias.isEmpty {
            return alias
        }
        
        return "@\(contact.contactUserId)"
    }
    
    private var initials: String {
        String(displayName.prefix(1)).uppercased()
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
