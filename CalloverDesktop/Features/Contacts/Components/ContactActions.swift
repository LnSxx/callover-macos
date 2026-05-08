//
//  ContactActions.swift
//  CalloverDesktop
//
//  Created by Leonid  on 08.05.26.
//

import SwiftUI

struct ContactActions: View {
    private let contact: Contact

    init(contact: Contact) {
        self.contact = contact
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
                    // TODO: Handle favourite action
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
                    // TODO: Handle mute action
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
                    // TODO: Handle block action
                }
            }
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )

            VStack(spacing: 0) {
                actionButton(
                    title: "Delete contact",
                    systemImage: "trash",
                    role: .destructive
                ) {
                    // TODO: Handle delete
                }
            }
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
            )
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
        updatedAt: Date()
    )

    ContactActions(contact: contact)
        .padding()
        .frame(width: 340)
}
