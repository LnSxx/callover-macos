//
//  ContactDetails.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactDetails: View {
    private let contact: Contact
    
    init(contact: Contact) {
        self.contact = contact
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoCard {
                InfoRow(title: "User ID", value: contact.contactUserId)
                
                Divider()
                
                InfoRow(title: "Alias", value: contact.alias ?? "No alias")
                
                Divider()
                
                InfoRow(title: "Note", value: contact.note ?? "")
            }
        }
    }
}

private struct InfoCard<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}

#Preview {
    let contact = Contact(
        id: "id",
        ownerId: "owner-id",
        contactUserId: "contact-user-id",
        alias: "My best friend",
        note: "Some note",
        isFavourite: false,
        isBlocked: false,
        isMuted: false,
        createdAt: Date(),
        updatedAt: Date(),
    )
    ContactDetails(contact: contact)
}
