//
//  CallView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 16.05.26.
//

import SwiftUI

struct CallView: View {
    @EnvironmentObject private var callStore: CallStore
    @EnvironmentObject private var contactsViewModel: ContactsViewModel
    @EnvironmentObject private var callCoordinator: CallCoordinator

    var body: some View {
        Group {
            if let call = callStore.call,
               call.direction == .incoming,
               call.status == .ringing {
                CallRingingBanner(
                    call: call,
                    contact: contact(for: call),
                    onAccept: {
                        callCoordinator.acceptCall()
                    },
                    onDecline: {
                        callCoordinator.declineCall()
                    }
                )
                .padding()
            }
        }
    }

    private func contact(for call: Call) -> Contact? {
        contactsViewModel.contacts.first {
            $0.contactUserId == call.callerUserId
        }
    }
}
