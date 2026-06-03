//
//  CallNotificationView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import SwiftUI

struct MissedCallNotificationView: View {
    @EnvironmentObject private var contactsViewModel: ContactsViewModel
    
    let callType: CallType
    let callerUserId: String
    let endedAt: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "phone.down.fill")
                    .frame(maxWidth: 40)
                    .foregroundStyle(.red)
                
                Text("Missed call")
                    .font(.title)
                    .foregroundStyle(.red)
            }
            
            VStack(alignment: .leading, spacing: 5){
                HStack {
                    Text("type:")
                        .monospaced()
                    Text(callType.rawValue)
                        .monospaced()
                }
                HStack {
                    Text("caller:")
                        .monospaced()
                    Text(callerText)
                        .monospaced()
                    if showStar {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                    if showBell {
                        Image(systemName: "bell.slash.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if showNoSign {
                        Image(systemName: "nosign")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }
            Text(Self.dateFormatter.string(from: endedAt))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .italic()
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private var contact: Contact? {
        contactsViewModel.contacts.first { $0.contactUserId == callerUserId }
    }
    
    private var callerText: String {
        if let contact {
            return contact.alias ?? contact.displayName
        }
        
        return "@\(callerUserId)"
    }
    
    private var showStar: Bool {
        if let contact {
            return contact.isFavourite
        }
        return false
    }
    
    private var showBell: Bool {
        if let contact {
            return contact.isMuted
        }
        return false
    }
    
    private var showNoSign: Bool {
        if let contact {
            return contact.isBlocked
        }
        return false
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        return formatter
    }()
}

#Preview {
    let contactsService = MockContactsService()
    let contactsViewModel = ContactsViewModel(service: contactsService)
    MissedCallNotificationView(
        callType: .audio,
        callerUserId: "peer-user-1",
        endedAt: Date()
    ).environmentObject(contactsViewModel)
}
