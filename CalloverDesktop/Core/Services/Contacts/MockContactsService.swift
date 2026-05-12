//
//  MockContactsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 11.05.26.
//

import Foundation

final class MockContactsService: ContactsServiceProtocol {
    private var contacts: [Contact]
    
    init(contacts: [Contact] = MockContactsService.defaultContacts) {
        self.contacts = contacts
    }
    
    func loadLocalContacts() async throws -> [Contact] {
        contacts
    }
    
    func syncContacts() async throws {}
    
    func isContactExistsLocally(userId: String) async throws -> Bool {
        return contacts.first(where: { $0.contactUserId == userId }) != nil
    }
    
    func createContact(params: CreateContactParams) async throws -> Contact {
        let contact = Contact(
            id: UUID().uuidString,
            ownerId: "mock-owner-id",
            contactUserId: params.userId,
            alias: params.name,
            note: nil,
            isFavourite: params.isAddingToFavourites ?? false,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        contacts.insert(contact, at: 0)
        
        return contact
    }
    
    func updateContact(params: UpdateContactParams) async throws -> Contact {
        guard let index = contacts.firstIndex(where: { $0.id == params.id }) else {
            throw MockContactsServiceError.contactNotFound
        }
        
        let oldContact = contacts[index]
        
        let updatedContact = Contact(
            id: oldContact.id,
            ownerId: oldContact.ownerId,
            contactUserId: oldContact.contactUserId,
            alias: params.newName ?? oldContact.alias,
            note: params.newNote ?? oldContact.note,
            isFavourite: params.isFavourite ?? oldContact.isFavourite,
            isBlocked: params.isBlocked ?? oldContact.isBlocked,
            isMuted: params.isMuted ?? oldContact.isMuted,
            createdAt: oldContact.createdAt,
            updatedAt: Date()
        )
        
        contacts[index] = updatedContact
        
        return updatedContact
    }
    
    func deleteContact(id: String) async throws {
        guard contacts.contains(where: { $0.id == id }) else {
            throw MockContactsServiceError.contactNotFound
        }
        
        contacts.removeAll { $0.id == id }
    }
}

extension MockContactsService {
    static let defaultContacts: [Contact] = [
        Contact(
            id: "contact-1",
            ownerId: "owner-1",
            contactUserId: "user-1",
            alias: "Peter I the Great",
            note: "Emperor of Russia",
            isFavourite: true,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-2",
            ownerId: "owner-1",
            contactUserId: "user-2",
            alias: "Catherine II the Great",
            note: "Empress of Russia",
            isFavourite: false,
            isBlocked: false,
            isMuted: true,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-3",
            ownerId: "owner-1",
            contactUserId: "user-3",
            alias: "Ivan IV the Terrible",
            note: "Tsar of all Roussie",
            isFavourite: false,
            isBlocked: true,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}

enum MockContactsServiceError: LocalizedError {
    case contactNotFound
    
    var errorDescription: String? {
        switch self {
        case .contactNotFound:
            return "Contact not found."
        }
    }
}
