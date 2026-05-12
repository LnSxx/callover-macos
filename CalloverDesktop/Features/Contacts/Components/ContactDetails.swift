//
//  ContactDetails.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactDetails: View {
    @Environment(\.contactsService) private var contactsService
    
    @State private var isShowingEditName = false
    @State private var isShowingEditNote = false
    
    private let contact: Contact
    let onUpdate: (Contact) -> Void
    
    init(
        contact: Contact,
        onUpdate: @escaping (Contact) -> Void,
    ) {
        self.contact = contact
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoCard {
                InfoRow(title: "User ID", value: contact.contactUserId)
                
                Divider()
                
                EditableInfoRow(
                    title: "Name",
                    value: contact.alias ?? "",
                    helpText: "Edit name",
                ) {
                    isShowingEditName = true
                }
                
                Divider()
                
                EditableInfoRow(
                    title: "Note",
                    value: contact.note ?? "",
                    helpText: "Edit note",
                ) {
                    isShowingEditNote = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditName) {
            EditContactNameView(
                contactsService: contactsService,
                contact: contact,
                onCancelTap: {
                    isShowingEditName = false
                },
                onUpdate: { updatedContact in
                    onUpdate(updatedContact)
                    isShowingEditName = false
                }
            )
        }
        .sheet(isPresented: $isShowingEditNote) {
            EditContactNoteView(
                contactsService: contactsService,
                contact: contact,
                onCancelTap: {
                    isShowingEditNote = false
                },
                onUpdate: { updatedContact in
                    onUpdate(updatedContact)
                    isShowingEditNote = false
                }
            )
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

private struct EditableInfoRow: View {
    let title: String
    let value: String
    let helpText: String
    let onEditTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.body)
                    .textSelection(.enabled)
            }
            
            Spacer()
            
            Button {
                onEditTap()
            } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(helpText)
        }
    }
}

#Preview {
    let service = MockContactsService()
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
    ContactDetails(
        contact: contact,
        onUpdate: {_ in }
    )
    .environment(\.contactsService, service)
}
