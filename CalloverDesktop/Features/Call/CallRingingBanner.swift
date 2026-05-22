//
//  CallRingingBanner.swift
//  CalloverDesktop
//
//  Created by Leonid  on 16.05.26.
//

import SwiftUI
import AudioToolbox

struct CallRingingBanner: View {
    let call: Call
    let contact: Contact?
    
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    private var displayName: String {
        contact?.displayName ?? call.callerUserId
    }
    
    private var initials: String {
        contact?.initials ?? ""
    }
    
    private var subtitle: String {
        switch call.type {
        case .audio:
            return "Incoming audio call"
        case .video:
            return "Incoming video call"
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ContactAvatar(
                initial: initials,
                variant: .medium
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                onDecline()
            } label: {
                Image(systemName: "phone.down.fill")
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            
            Button {
                onAccept()
            } label: {
                Image(systemName: "phone.fill")
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accent)
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(radius: 10)
        .frame(maxWidth: 520)
        .onAppear {
            AudioServicesPlaySystemSound(1000)
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
    let call = Call(
        callerUserId: "caller",
        calleeUserId: "callee",
        direction: .incoming,
        status: .ringing,
        type: .video,
        remoteDescription: nil,
    )
    CallRingingBanner(
        call: call,
        contact: contact,
        onAccept: {},
        onDecline: {},
    )
}
