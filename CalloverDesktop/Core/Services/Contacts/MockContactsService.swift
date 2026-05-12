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
            note: "Tsar of all Russia",
            isFavourite: false,
            isBlocked: true,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-4",
            ownerId: "owner-1",
            contactUserId: "user-4",
            alias: "Nicholas II",
            note: "Last Emperor of Russia",
            isFavourite: false,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-5",
            ownerId: "owner-1",
            contactUserId: "user-5",
            alias: "Alexander I",
            note: "Defeated Napoleon",
            isFavourite: true,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-6",
            ownerId: "owner-1",
            contactUserId: "user-6",
            alias: "Alexander II",
            note: "Liberator of the serfs",
            isFavourite: false,
            isBlocked: false,
            isMuted: true,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-7",
            ownerId: "owner-1",
            contactUserId: "user-7",
            alias: "Alexander III",
            note: "Peacemaker Emperor",
            isFavourite: false,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-8",
            ownerId: "owner-1",
            contactUserId: "user-8",
            alias: "Paul I",
            note: "Son of Catherine II",
            isFavourite: false,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-9",
            ownerId: "owner-1",
            contactUserId: "user-9",
            alias: "Elizabeth Petrovna",
            note: "Daughter of Peter the Great",
            isFavourite: true,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-10",
            ownerId: "owner-1",
            contactUserId: "user-10",
            alias: "Anna Ioannovna",
            note: "Empress of Russia",
            isFavourite: false,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-11",
            ownerId: "owner-1",
            contactUserId: "user-11",
            alias: "Boris Godunov",
            note: "Tsar during the Time of Troubles",
            isFavourite: false,
            isBlocked: false,
            isMuted: true,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-12",
            ownerId: "owner-1",
            contactUserId: "user-12",
            alias: "Mikhail Romanov",
            note: "First Romanov tsar",
            isFavourite: false,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-13",
            ownerId: "owner-1",
            contactUserId: "user-13",
            alias: "Alexei Mikhailovich",
            note: "Father of Peter the Great",
            isFavourite: false,
            isBlocked: true,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-14",
            ownerId: "owner-1",
            contactUserId: "user-14",
            alias: "Feodor I",
            note: "Son of Ivan the Terrible",
            isFavourite: false,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-15",
            ownerId: "owner-1",
            contactUserId: "user-15",
            alias: "Peter II",
            note: "Grandson of Peter the Great",
            isFavourite: false,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-16",
            ownerId: "owner-1",
            contactUserId: "user-16",
            alias: "Peter III",
            note: "Husband of Catherine II",
            isFavourite: false,
            isBlocked: false,
            isMuted: true,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-17",
            ownerId: "owner-1",
            contactUserId: "user-17",
            alias: "Nicholas I",
            note: "Emperor during the Decembrist revolt",
            isFavourite: true,
            isBlocked: false,
            isMuted: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Contact(
            id: "contact-18",
            ownerId: "owner-1",
            contactUserId: "user-18",
            alias: "Feodor III",
            note: "Older brother of Peter the Great",
            isFavourite: false,
            isBlocked: false,
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
