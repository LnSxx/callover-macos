//
//  ContactsViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation
import Combine

@MainActor
final class ContactsViewModel: ObservableObject {
    @Published private(set) var contacts: [Contact] = []
    @Published private(set) var isSyncing = false
    @Published var errorMessage: String?
    
    private let service: ContactsServiceProtocol
    
    init(service: ContactsServiceProtocol) {
        self.service = service
        Task {
            await load()
        }
    }
    
    func load() async {
        do {
            contacts = try await service.loadLocalContacts()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        await sync()
    }
    
    func sync() async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            try await service.syncContacts()
            contacts = try await service.loadLocalContacts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func insertContact(contact: Contact) {
        contacts.removeAll { $0.id == contact.id }
        
        contacts.append(contact)
        
        contacts.sort {
            $0.alias?.localizedCaseInsensitiveCompare($1.alias ?? $1.contactUserId) == .orderedAscending
        }
    }
}
