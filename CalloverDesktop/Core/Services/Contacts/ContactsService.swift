//
//  ContactsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

protocol ContactsServiceProtocol {
    func loadLocalContacts() async throws -> [Contact]
    func syncContacts() async throws
    func isContactExistsLocally(userId: String) async throws -> Bool
    func createContact(
        userId: String,
        name: String,
        isAddingToFavourites: Bool,
    ) async throws -> Contact
}

class ContactsService: ContactsServiceProtocol {
    private let remoteDataSource: RemoteContactsServiceProtocol
    private let localDataSource: LocalContactsServiceProtocol
    private let syncStateService: SyncStateServiceProtocol
    
    init(remoteDataSource: RemoteContactsServiceProtocol, localDataSource: LocalContactsServiceProtocol, syncStateService: SyncStateServiceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.syncStateService = syncStateService
    }
    
    func loadLocalContacts() async throws -> [Contact] {
        return try await localDataSource.fetchContacts()
    }
    
    func syncContacts() async throws {
        let lastSyncAt = try await syncStateService.getLastSyncAt(key: "contacts")
        
        var cursor: String? = nil
        var downloadedContacts: [ContactDTO] = []
        
        repeat {
            let page = try await remoteDataSource.fetchContacts(
                changedAfter: lastSyncAt,
                cursor: cursor,
                limit: 100
            )
            
            downloadedContacts.append(contentsOf: page.items)
            cursor = page.nextCursor
        } while cursor != nil
        
        if !downloadedContacts.isEmpty {
            try await localDataSource.upsertContacts(downloadedContacts)
        }
        
        try await syncStateService.setLastSyncAt(key: "contacts", date: Date())
    }
    
    func isContactExistsLocally(userId: String) async throws -> Bool {
        try await localDataSource.getContactByUserId(userId: userId) != nil
    }
    
    func createContact(
        userId: String,
        name: String,
        isAddingToFavourites: Bool,
    ) async throws -> Contact {
        let createdContactDto = try await remoteDataSource.createContact(
            contactUserId: userId,
            name: name,
            isAddingToFavourites: isAddingToFavourites
        )
        try await localDataSource.upsertContact(createdContactDto)
        return createdContactDto.toDomain()
    }
}



