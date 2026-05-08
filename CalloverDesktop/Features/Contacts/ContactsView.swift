//
//  ContactsView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var viewModel: ContactsViewModel

    @State private var selectedContact: Contact?
    @State private var isShowingInspector = true

    var body: some View {
        List(selection: $selectedContact) {
            ForEach(viewModel.contacts) { contact in
                ContactListRow(contact: contact)
                    .tag(contact)
            }
        }
        .navigationTitle("Contacts")
        .toolbar {
            ToolbarItem {
                Button {
                    isShowingInspector.toggle()
                } label: {
                    Image(systemName: "sidebar.right")
                }
            }
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
    let remoteDataSource = RemoteContactsService()
    let localDataSource = LocalContactsService(context: PersistenceController.shared.viewContext)
    let syncState = SyncStateService(context: PersistenceController.shared.viewContext)
    let service = ContactsService(
        remoteDataSource: remoteDataSource, localDataSource: localDataSource, syncStateService: syncState
    )
    let viewModel = ContactsViewModel(service: service)
    ContactsView()
        .environmentObject(viewModel)
}
