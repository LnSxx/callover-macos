//
//  ContactActions.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactActions: View {
    @Environment(\.contactsService) var contactsService
    @State private var actionErrorMessage: String?
    @State private var isShowingDeleteConfirmation = false
    
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
    
    private func setActionErrorMessage() {
        actionErrorMessage = "Failed to complete action. Please try again later."
    }
    
    private func clearActionErrorMessage() {
        actionErrorMessage = nil
    }
    
    private func updateContact(_ params: UpdateContactParams) {
        Task {
            do {
                clearActionErrorMessage()
                
                let updatedContact = try await contactsService.updateContact(
                    params: params
                )
                
                onUpdate(updatedContact)
            } catch {
                setActionErrorMessage()
            }
        }
    }
    
    private func deleteContact() {
        Task {
            do {
                clearActionErrorMessage()
                
                try await contactsService.deleteContact(id: contact.id)
                
                onDelete(contact)
            } catch {
                setActionErrorMessage()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 0) {
                actionButton(
                    title: contact.isFavourite
                    ? "Remove from favourites"
                    : "Add to favourites",
                    systemImage: contact.isFavourite
                    ? "star.slash.fill"
                    : "star.fill"
                ) {
                    updateContact(
                        UpdateContactParams(
                            id: contact.id,
                            isFavourite: !contact.isFavourite
                        )
                    )
                }
                
                Divider()
                
                actionButton(
                    title: contact.isMuted
                    ? "Unmute"
                    : "Mute",
                    systemImage: contact.isMuted
                    ? "bell.fill"
                    : "bell.slash.fill"
                ) {
                    updateContact(
                        UpdateContactParams(
                            id: contact.id,
                            isMuted: !contact.isMuted
                        )
                    )
                }
                
                Divider()
                
                actionButton(
                    title: contact.isBlocked
                    ? "Unblock"
                    : "Block",
                    systemImage: contact.isBlocked
                    ? "nosign"
                    : "nosign"
                ) {
                    updateContact(
                        UpdateContactParams(
                            id: contact.id,
                            isBlocked: !contact.isBlocked
                        )
                    )
                }
            }
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )
            
            if let actionErrorMessage {
                Text(actionErrorMessage)
                    .font(.callout)
                    .foregroundStyle(.red)
            }
            
            VStack(spacing: 0) {
                actionButton(
                    title: "Delete contact",
                    systemImage: "trash",
                    role: .destructive
                ) {
                    isShowingDeleteConfirmation = true
                }
            }
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )
            .confirmationDialog(
                "Delete Contact?",
                isPresented: $isShowingDeleteConfirmation
            ) {
                Button("Delete contact", role: .destructive) {
                    deleteContact()
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this contact?")
            }
        }
    }
    
    private func actionButton(
        title: String,
        systemImage: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(
                        role == .destructive
                        ? .red
                        : .secondary
                    )
                    .frame(width: 18)
                
                Text(title)
                    .foregroundStyle(
                        role == .destructive
                        ? .red
                        : .primary
                    )
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let service = MockContactsService()
    let viewModel = ContactsViewModel(service: service)
    let contact = Contact(
        id: "contact-2",
        ownerId: "owner-1",
        contactUserId: "user-2",
        alias: "Catherine II the Great",
        note: "Empress of Russia",
        isFavourite: false,
        isBlocked: false,
        isMuted: true,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    ContactActions(
        contact: contact,
        onUpdate: { _ in },
        onDelete: { _ in }
    )
    .padding()
    .frame(width: 340)
    .environmentObject(viewModel)
    .environment(\.contactsService, service)
}
