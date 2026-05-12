//
//  EditContactNameViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.05.26.
//

import Foundation
import Combine

struct EditContactNameFormState {
    var name = ""
    
    var nameError: String?
    var submitError: String?
    var isLoading = false
}

@MainActor
final class EditContactNameViewModel: ObservableObject {
    @Published var state = EditContactNameFormState()
    
    private let contactsService: ContactsServiceProtocol
    private let contact: Contact
    
    init(
        contactsService: ContactsServiceProtocol,
        contact: Contact,
    ) {
        self.contactsService = contactsService
        self.contact = contact
        state.name = contact.alias ?? ""
    }
    
    private func validateForm() -> Bool {
        state.nameError = nil
        state.submitError = nil

        let trimmedName = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentName = contact.alias?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if currentName == trimmedName {
            state.nameError = "New name is the same as the current name"
        }

        if case .failure(let error) = Validator.validateNewContactName(trimmedName) {
            state.nameError = error.errorDescription
        }

        return state.nameError == nil
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
            case .alias:
                state.nameError = error.code.message
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
        
        let name = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        state.isLoading = true
        state.submitError = nil
        
        defer { state.isLoading = false }
        do {
            let params = UpdateContactParams(
                id: contact.id,
                newName: name,
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
