//
//  ActiveCall.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.05.26.
//

import SwiftUI

struct ActiveCall: View {
    @EnvironmentObject private var callMediaStore: CallMediaStore
    
    let call: Call
    let contact: Contact?
    let onEnd: () -> Void
    
    var body: some View {
        ZStack {
            if let localMedia = callMediaStore.localVideoTrack {
                RTCVideoTrackView(track: localMedia)
            }
            
            
            VStack {
                HStack {
                    Spacer()
                    
                    if let remoteMedia = callMediaStore.remoteVideoTrack {
                        RTCVideoTrackView(track: remoteMedia)
                            .frame(width: 220, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding()
                    }
                }
                
                Spacer()
                
                Button(role: .destructive) {
                    onEnd()
                } label: {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .frame(width: 64, height: 64)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        direction: .outgoing,
        status: .calling,
        type: .video,
        remoteDescription: nil,
    )
    ActiveCall(
        call: call, contact: contact, onEnd: {}
    )
}
