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
    
    func createContact(
        userId: String,
        name: String,
        isAddingToFavourites: Bool,
    ) async throws -> Contact {
        let contact = Contact(
            id: UUID().uuidString,
            ownerId: "mock-owner-id",
            contactUserId: userId,
            alias: name,
            note: nil,
            isFavourite: isAddingToFavourites,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        contacts.insert(contact, at: 0)
        
        return contact
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
