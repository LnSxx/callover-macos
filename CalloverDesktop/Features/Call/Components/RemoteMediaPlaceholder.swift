//
//  RemoteMediaPlaceholder.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.05.26.
//

import SwiftUI

struct RemoteVideoPlaceholder: View {
    let contact: Contact?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.92))

            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)

                Text(contact?.displayName ?? "Calling...")
                    .font(.title2)
                    .foregroundStyle(.white)

//                Text("Waiting for remote video")
//                    .font(.callout)
//                    .foregroundStyle(.secondary)
            }
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
    RemoteVideoPlaceholder(contact: contact)
}
