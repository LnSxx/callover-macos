//
//  AddContactViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 11.05.26.
//

import Foundation
import Combine

struct AddContactFormState {
    var userId = ""
    var name = ""
    
    var userIdError: String?
    var nameError: String?
    var isAddingToFavourites = false
    var submitError: String?
    var isLoading = false
}

@MainActor
final class AddContactViewModel: ObservableObject {
    @Published var state = AddContactFormState()
    
    private let contactsService: ContactsServiceProtocol
//    private let onSaved: (Contact) -> Void
    
    init(
        contactsService: ContactsServiceProtocol,
//        onSaved: @escaping (Contact) -> Void
    ) {
        self.contactsService = contactsService
//        self.onSaved = onSaved
    }
    
    func toggleAddingToFavourites() {
        state.isAddingToFavourites.toggle()
    }
    
    private func validateForm() -> Bool {
        state.userIdError = nil
        state.nameError = nil
        state.submitError = nil

        if case .failure(let error) = Validator.validateNewContactUserId(state.userId) {
            state.userIdError = error.errorDescription
        }

        if case .failure(let error) = Validator.validateNewContactName(state.name) {
            state.nameError = error.errorDescription
        }

        return state.userIdError == nil && state.nameError == nil
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
        case .CONFLICT:
            state.userIdError = "Contact already exists"
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
            case .contactUserId:
                state.userIdError = error.code.message
            case .alias:
                state.nameError = error.code.message
            default:
                return
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
        
        let userContactId = state.userId
        let name = state.name
        let isAddingToFavourites = state.isAddingToFavourites
        
        do {
            let exists = try await contactsService.isContactExistsLocally(userId: userContactId)

            if exists {
                state.userIdError = "Contact already exists"
                return nil
            }
        } catch {
            setDefaultSubmitErrorMessage()
            return nil
        }
        
        state.isLoading = true
        state.submitError = nil
        
        defer { state.isLoading = false }
        do {
            return try await contactsService.createContact(
                userId: userContactId,
                name: name,
                isAddingToFavourites: isAddingToFavourites
            )
        } catch let error as NetworkError {
            apply(error)
            return nil
        } catch {
            setDefaultSubmitErrorMessage()
            return nil
        }
    }
}
