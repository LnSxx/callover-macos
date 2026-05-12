//
//  EditContactNoteViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.05.26.
//

import Foundation
import Combine

struct EditContactNoteFormState {
    var note = ""
    
    var noteError: String?
    var submitError: String?
    var isLoading = false
}

@MainActor
final class EditContactNoteViewModel: ObservableObject {
    @Published var state = EditContactNoteFormState()
    
    private let contactsService: ContactsServiceProtocol
    private let contact: Contact
    
    init(
        contactsService: ContactsServiceProtocol,
        contact: Contact,
    ) {
        self.contactsService = contactsService
        self.contact = contact
        state.note = contact.note ?? ""
    }
    
    private func validateForm() -> Bool {
        state.noteError = nil
        state.submitError = nil
        
        let trimmedName = state.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentName = contact.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if currentName == trimmedName {
            state.noteError = "New note is the same as the current note"
        }
        
        if case .failure(let error) = Validator.validateContactNote(trimmedName) {
            state.noteError = error.errorDescription
        }
        
        return state.noteError == nil
    }
    
    private func apply(_ error: NetworkError) {
        switch error {
        case .errorResponse(let response):
            apply(response)
        default:
            setDefaultSubmitErrorMessage()
        }
    }
    
    private func apply(_ response: ErrorResponse) {
        switch response.code {
        case .VALIDATION_ERROR:
            guard let errors = response.errors else {
                setDefaultSubmitErrorMessage()
                return
            }
            
            applyValidationErrors(errors)
            
        default:
            setDefaultSubmitErrorMessage()
        }
    }
    
    private func applyValidationErrors(_ errors: [ERValidationError]) {
        for error in errors {
            switch error.field {
            case .note:
                state.noteError = error.code.message
            default:
                continue
            }
        }
    }
    
    private func setDefaultSubmitErrorMessage() {
        state.submitError = "Something went wrong"
    }
    
    func submit() async -> Contact? {
        guard !state.isLoading else {
            return nil
        }
        
        guard validateForm() else {
            return nil
        }
        
        let note = state.note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        state.isLoading = true
        state.submitError = nil
        
        defer { state.isLoading = false }
        do {
            let params = UpdateContactParams(
                id: contact.id,
                newNote: note,
            )
            return try await contactsService.updateContact(params: params)
        } catch let error as NetworkError {
            apply(error)
            return nil
        } catch {
            setDefaultSubmitErrorMessage()
            return nil
        }
    }
}

