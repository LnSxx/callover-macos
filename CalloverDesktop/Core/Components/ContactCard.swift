//
//  ContactCard.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import SwiftUI

struct ContactCard: View {
    let contact: Contact
    let isOnline: Bool
    
    let onStartVideoCallTap: () -> Void
    let onStartAudioCallTap: () -> Void
    
    init(
        contact: Contact,
        isOnline: Bool,
        onStartVideoCallTap: @escaping () -> Void,
        onStartAudioCallTap: @escaping () -> Void
    ) {
        self.contact = contact
        self.isOnline = isOnline
        self.onStartVideoCallTap = onStartVideoCallTap
        self.onStartAudioCallTap = onStartAudioCallTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            avatar
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(contact.displayName)
                        .font(.title)
                        .bold()
                    
                    if contact.isFavourite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
            }
            
            HStack(spacing: 8) {
                Button {
                    onStartVideoCallTap()
                } label: {
                    Label("Video call", systemImage: "video.fill")
                }
                
                Button {
                    onStartAudioCallTap()
                } label: {
                    Label("Audio call", systemImage: "phone.fill")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
        .frame(maxWidth: 220, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var avatar: some View {
        ContactAvatar(
            initial: contact.initials,
            variant: .medium
        )
        .overlay(alignment: .topTrailing) {
            OnlineIndicator(isOnline: isOnline)
                .offset(x: 2, y: -2)
        }
    }
}

private struct OnlineIndicator: View {
    let isOnline: Bool
    
    var body: some View {
        Circle()
            .fill(.green)
            .frame(width: 12, height: 12)
            .overlay {
                Circle()
                    .stroke(.background, lineWidth: 2)
            }
            .scaleEffect(isOnline ? 1 : 0.2)
            .opacity(isOnline ? 1 : 0)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isOnline)
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
    ContactCard(
        contact: contact,
        isOnline: true,
        onStartVideoCallTap: {},
        onStartAudioCallTap: {},
    )
}
