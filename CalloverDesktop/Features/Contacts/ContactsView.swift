//
//  ContactsView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

private enum ContactsFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case favourites = "Favourites"

    var id: Self { self }
}

struct ContactsView: View {
    @EnvironmentObject private var contactsViewModel: ContactsViewModel
    @Environment(\.contactsService) private var contactsService

    @State private var selectedContact: Contact?
    @State private var isShowingInspector = true
    @State private var isShowingAddContact = false
    @State private var filter: ContactsFilter = .all
    @State private var searchText = ""

    private var visibleContacts: [Contact] {
        contactsViewModel.contacts
            .filter(matchesFilter)
            .filter(matchesSearch)
    }

    var body: some View {
        contactsList
            .navigationTitle("Contacts")
            .searchable(
                text: $searchText,
                placement: .sidebar,
                prompt: "Search contacts"
            )
            .toolbar {
                leadingToolbarItems
                trailingToolbarItems
            }
            .sheet(isPresented: $isShowingAddContact) {
                addContactSheet
            }
            .inspector(isPresented: $isShowingInspector) {
                inspectorContent
            }
    }
}

private extension ContactsView {
    var contactsList: some View {
        List(selection: $selectedContact) {
            ForEach(visibleContacts) { contact in
                ContactListRow(contact: contact)
                    .tag(contact)
            }
        }
    }

    var leadingToolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Picker("Filter", selection: $filter) {
                ForEach(ContactsFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 180)

            Button {
                isShowingAddContact = true
            } label: {
                Label("Add Contact", systemImage: "plus")
            }
        }
    }

    var trailingToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                isShowingInspector.toggle()
            } label: {
                Image(systemName: "sidebar.right")
            }
        }
    }

    var addContactSheet: some View {
        AddContactView(
            contactsService: contactsService,
            onCancelTap: {
                isShowingAddContact = false
            },
            onSaved: onCreateContact
        )
    }

    @ViewBuilder
    var inspectorContent: some View {
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

    func matchesFilter(_ contact: Contact) -> Bool {
        switch filter {
        case .all:
            return true
        case .favourites:
            return contact.isFavourite
        }
    }

    func matchesSearch(_ contact: Contact) -> Bool {
        guard !searchText.isEmpty else {
            return true
        }

        let alias = contact.alias ?? ""
        let userId = contact.contactUserId

        return alias.localizedCaseInsensitiveContains(searchText)
            || userId.localizedCaseInsensitiveContains(searchText)
    }

    func onCreateContact(_ contact: Contact) {
        contactsViewModel.upsertContact(contact: contact)
        selectedContact = contact
        isShowingInspector = true
        isShowingAddContact = false
    }

    func onContactUpdate(_ contact: Contact) {
        contactsViewModel.upsertContact(contact: contact)
        selectedContact = contact
        isShowingInspector = true
    }

    func onContactDelete(_ contact: Contact) {
        contactsViewModel.deleteContact(id: contact.id)
        selectedContact = nil
        isShowingInspector = false
    }
}

#Preview {
    let service = MockContactsService()
    let viewModel = ContactsViewModel(service: service)
    ContactsView()
        .environmentObject(viewModel)
        .environment(\.contactsService, service)
}
