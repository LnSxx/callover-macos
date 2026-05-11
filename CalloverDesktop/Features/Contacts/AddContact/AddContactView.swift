//
//  AddContactView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 11.05.26.
//

import SwiftUI

struct AddContactView: View {
    @StateObject private var addContactViewModel: AddContactViewModel
    
    let onCancelTap: () -> Void
    let onSaved: (Contact) -> Void
    
    init(
        contactsService: ContactsServiceProtocol,
        onCancelTap: @escaping () -> Void,
        onSaved: @escaping (Contact) -> Void
    ) {
        let viewModel = AddContactViewModel(
            contactsService: contactsService
        )
        _addContactViewModel = StateObject(wrappedValue: viewModel)
        self.onCancelTap = onCancelTap
        self.onSaved = onSaved
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add new contact")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("User ID", text: $addContactViewModel.state.userId)
                        .disabled(addContactViewModel.state.isLoading)
                    
                    if let error = addContactViewModel.state.userIdError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Name", text: $addContactViewModel.state.name)
                        .disabled(addContactViewModel.state.isLoading)

                    
                    if let error = addContactViewModel.state.nameError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Toggle(isOn: $addContactViewModel.state.isAddingToFavourites) {
                    Text("Add to favourites")
                }
                .disabled(addContactViewModel.state.isLoading)
            }
            
            if let errorMessage = addContactViewModel.state.submitError {
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
                .disabled(addContactViewModel.state.isLoading)
                
                Button("Add") {
                    Task {
                        if let contact = await addContactViewModel.submit() {
                            onSaved(contact)
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(addContactViewModel.state.isLoading)
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}

#Preview {
    let contactsService = MockContactsService()
    AddContactView(
        contactsService: contactsService,
        onCancelTap: {},
        onSaved: {contact in }
    )
}
