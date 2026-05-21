//
//  HomeView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var contactsViewModel: ContactsViewModel
    @EnvironmentObject private var presenceStore: PresenceStore
    @EnvironmentObject private var callCoordinator: CallCoordinator
    
    @StateObject private var viewModel = HomeViewModel()
    
    let onAddContactTap: () -> Void
    
    init(onAddContactTap: @escaping () -> Void = {}) {
        self.onAddContactTap = onAddContactTap
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 16)
    ]
    
    var body: some View {
        Group {
            if contactsViewModel.contacts.isEmpty {
                emptyContactsView
            } else {
                contactsGrid
            }
        }
        .navigationTitle("Home")
        .onAppear {
            updateHomeContacts()
        }
        .onChange(of: contactsViewModel.contacts) { _, _ in
            updateHomeContacts()
        }
    }
    
    private var contactsGrid: some View {
        let onlineUserIds = presenceStore.onlineUserIds
        
        return ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                ForEach(viewModel.contacts) { contact in
                    ContactCard(
                        contact: contact,
                        isOnline: onlineUserIds.contains(contact.contactUserId),
                        onStartVideoCallTap: {
                            callCoordinator.startCall(
                                targetUserId: contact.contactUserId,
                                type: .video
                            )
                        },
                        onStartAudioCallTap: {
                            callCoordinator.startCall(
                                targetUserId: contact.contactUserId,
                                type: .audio
                            )
                        },
                    )
                }
            }
            .padding()
        }
    }
    
    private var emptyContactsView: some View {
        ContentUnavailableView {
            Label("No Contacts", systemImage: "person.crop.circle.badge.plus")
        } description: {
            Text("Add your first contact to start calling.")
        } actions: {
            Button {
                onAddContactTap()
            } label: {
                Label("Add Contact", systemImage: "plus")
            }
        }
    }
    
    private func updateHomeContacts() {
        viewModel.updateContacts(
            contactsViewModel.contacts,
            onlineUserIds: presenceStore.onlineUserIds
        )
    }
}

#Preview {
    let contactsService = MockContactsService()
    let contactsViewModel = ContactsViewModel(service: contactsService)
    let presenceStore = PresenceStore()
    let callCoordinator = MockCallCoordinator()
        
    HomeView()
        .environmentObject(contactsViewModel)
        .environmentObject(presenceStore)
        .environmentObject(callCoordinator)
}
