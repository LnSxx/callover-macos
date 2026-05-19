//
//  ContactsView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    @Environment(\.contactsService) var contactsService
    
    @State private var selectedContactId: Contact.ID?
    @State private var isShowingInspector = true
    @State private var isShowingAddContact = false
    @State private var searchText = ""
    
    private var selectedContact: Contact? {
        contactsViewModel.contacts.first { $0.id == selectedContactId }
    }
    
    private func onCreateContact(contact: Contact) {
        contactsViewModel.upsertContact(contact: contact)
        
        selectedContactId = contact.id
        isShowingInspector = true
        isShowingAddContact = false
    }
    
    private func onContactUpdate(contact: Contact) {
        contactsViewModel.upsertContact(contact: contact)
        selectedContactId = contact.id
        isShowingInspector = true
    }
    
    private func onContactDelete(contact: Contact) {
        contactsViewModel.deleteContact(id: contact.id)
        selectedContactId = nil
        isShowingInspector = false
    }
    
    private var visibleContacts: [Contact] {
        var contacts = contactsViewModel.contacts
        
        if !searchText.isEmpty {
            contacts = contacts.filter {
                let alias = $0.alias ?? ""
                let userId = $0.contactUserId
                
                return alias.localizedCaseInsensitiveContains(searchText)
                || userId.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return contacts
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search contacts", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            
            List(selection: $selectedContactId) {
                ForEach(visibleContacts) { contact in
                    ContactListRow(contact: contact)
                        .tag(contact.id)
                }
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
                    onCreateContact(contact: contact)
                }
            )
        }
        .inspector(isPresented: $isShowingInspector) {
            if let selectedContact {
                ContactInfo(
                    contact: selectedContact,
                    onUpdate: onContactUpdate,
                    onDelete: onContactDelete
                )
                .inspectorColumnWidth(min: 320, ideal: 320, max: 500)
            } else {
                ContentUnavailableView(
                    "No Contact Selected",
                    systemImage: "person.crop.circle"
                )
                .inspectorColumnWidth(min: 320, ideal: 320, max: 500)
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
