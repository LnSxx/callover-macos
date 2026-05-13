//
//  ContactInfoView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactInfo: View {
    private let contact: Contact
    let onUpdate: (Contact) -> Void
    let onDelete: (Contact) -> Void
    
    init(
        contact: Contact,
        onUpdate: @escaping (Contact) -> Void,
        onDelete: @escaping (Contact) -> Void,
    ) {
        self.contact = contact
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 18) {
                ContactAvatar(
                    initial: contact.initials,
                    variant: .large,
                )
                
                Text(contact.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if (
                    contact.isFavourite ||
                    contact.isMuted ||
                    contact.isBlocked
                ) {
                    ContactStatus(
                        isFavourite: contact.isFavourite,
                        isMuted: contact.isMuted,
                        isBlocked: contact.isBlocked,
                    )
                }
                
                ContactDetails(
                    contact: contact,
                    onUpdate: onUpdate,
                )
                
                ContactActions(
                    contact: contact,
                    onUpdate: onUpdate,
                    onDelete: onDelete,
                )
            }
            .padding(32)
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
        isFavourite: true,
        isBlocked: false,
        isMuted: false,
        createdAt: Date(),
        updatedAt: Date(),
    )
    ContactInfo(
        contact: contact,
        onUpdate: {_ in },
        onDelete: {_ in },
    )
}
