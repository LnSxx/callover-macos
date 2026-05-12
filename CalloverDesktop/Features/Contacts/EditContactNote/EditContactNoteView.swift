//
//  EditContactNoteView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.05.26.
//

import SwiftUI

struct EditContactNoteView: View {
    @StateObject private var editContactNoteVM: EditContactNoteViewModel
    
    let onCancelTap: () -> Void
    let onUpdate: (Contact) -> Void
    
    init(
        contactsService: ContactsServiceProtocol,
        contact: Contact,
        onCancelTap: @escaping () -> Void,
        onUpdate: @escaping (Contact) -> Void
    ) {
        let viewModel = EditContactNoteViewModel(
            contactsService: contactsService,
            contact: contact,
        )
        _editContactNoteVM = StateObject(wrappedValue: viewModel)
        self.onCancelTap = onCancelTap
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit contact note")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    TextEditor(text: $editContactNoteVM.state.note)
                        .frame(minHeight: 140)
                        .disabled(editContactNoteVM.state.isLoading)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.quaternary)
                        }
                        .onChange(of: editContactNoteVM.state.note) { _, newValue in
                            if newValue.count > 500 {
                                editContactNoteVM.state.note = String(newValue.prefix(500))
                            }
                        }

                    HStack {
                        if let error = editContactNoteVM.state.noteError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        Spacer()

                        Text("\(editContactNoteVM.state.note.count)/500")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if let errorMessage = editContactNoteVM.state.submitError {
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
                .disabled(editContactNoteVM.state.isLoading)
                
                Button("Save") {
                    Task {
                        if let contact = await editContactNoteVM.submit() {
                            onUpdate(contact)
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(editContactNoteVM.state.isLoading)
            }
        }
        .padding(24)
        .frame(width: 520)
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
    EditContactNoteView(
        contactsService: service,
        contact: contact,
        onCancelTap: {},
        onUpdate: {_ in}
    )
    
}
