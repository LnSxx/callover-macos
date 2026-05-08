//
//  ContactInfoView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactInfo: View {
    private let contact: Contact
    
    init(contact: Contact) {
        self.contact = contact
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 18) {
                avatar
                
                Text(title)
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
                
                ContactDetails(contact: contact)
                
                ContactActions(contact: contact)
            }
            .padding(32)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
    }
    
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
            
            if let initial {
                Text(initial)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.primary)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 76, height: 76)
    }
    
    private var initial: String? {
        guard let alias = contact.alias?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !alias.isEmpty,
              let firstCharacter = alias.first else {
            return nil
        }
        
        return String(firstCharacter).uppercased()
    }
    
    private var title: String {
        contact.alias ?? "@\(contact.contactUserId)"
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
    ContactInfo(contact: contact)
}
