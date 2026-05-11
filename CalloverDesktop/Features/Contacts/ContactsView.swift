//
//  ContactsView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var viewModel: ContactsViewModel
    @Environment(\.contactsService) var contactsService
    
    @State private var selectedContact: Contact?
    @State private var isShowingInspector = true
    @State private var isShowingAddContact = false
    
    var body: some View {
        List(selection: $selectedContact) {
            ForEach(viewModel.contacts) { contact in
                ContactListRow(contact: contact)
                    .tag(contact)
            }
        }
        .navigationTitle("Contacts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddContact = true
                } label: {
                    Label("Add Contact", systemImage: "plus")
                }
            }
            
            ToolbarItem {
                Button {
                    isShowingInspector.toggle()
                } label: {
                    Image(systemName: "sidebar.right")
                }
            }
        }
        .sheet(isPresented: $isShowingAddContact) {
            AddContactView(
                contactsService: contactsService,
                onCancelTap: {
                    isShowingAddContact = false
                },
                onSaved: { contact in
                    viewModel.insertContact(contact: contact)
                    
                    selectedContact = contact
                    isShowingInspector = true
                    isShowingAddContact = false
                }
            )
        }
        .inspector(isPresented: $isShowingInspector) {
            if let selectedContact {
                ContactInfo(contact: selectedContact)
                    .inspectorColumnWidth(
                        min: 320,
                        ideal: 320,
                        max: 500
                    )
            } else {
                ContentUnavailableView(
                    "No Contact Selected",
                    systemImage: "person.crop.circle"
                )
                .inspectorColumnWidth(
                    min: 320,
                    ideal: 320,
                    max: 500
                )
            }
        }
    }
}

#Preview {
    let service = MockContactsService()
    let viewModel = ContactsViewModel(service: service)
    ContactsView()
        .environmentObject(viewModel)
        .environment(\.contactsService, service)
}
