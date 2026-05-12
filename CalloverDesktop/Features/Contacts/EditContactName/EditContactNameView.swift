//
//  EditContactNameView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.05.26.
//

import SwiftUI

struct EditContactNameView: View {
    @StateObject private var editContactNameVM: EditContactNameViewModel
    
    let onCancelTap: () -> Void
    let onUpdate: (Contact) -> Void
    
    init(
        contactsService: ContactsServiceProtocol,
        contact: Contact,
        onCancelTap: @escaping () -> Void,
        onUpdate: @escaping (Contact) -> Void
    ) {
        let viewModel = EditContactNameViewModel(
            contactsService: contactsService,
            contact: contact,
        )
        _editContactNameVM = StateObject(wrappedValue: viewModel)
        self.onCancelTap = onCancelTap
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit contact name")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Name", text: $editContactNameVM.state.name)
                        .disabled(editContactNameVM.state.isLoading)

                    
                    if let error = editContactNameVM.state.nameError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            if let errorMessage = editContactNameVM.state.submitError {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.red)
            }
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    onCancelTap()
                }
                .keyboardShortcut(.cancelAction)
                .disabled(editContactNameVM.state.isLoading)
                
                Button("Save") {
                    Task {
                        if let contact = await editContactNameVM.submit() {
                            onUpdate(contact)
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(editContactNameVM.state.isLoading)
            }
        }
        .padding(24)
        .frame(width: 420)
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
    let service = MockContactsService()
    EditContactNameView(
        contactsService: service,
        contact: contact,
        onCancelTap: {},
        onUpdate: {_ in}
    )
    
}
