//
//  ContactsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

struct CreateContactParams {
    let userId: String
    let name: String
    let isAddingToFavourites: Bool?
}

struct UpdateContactParams {
    var id: String
    var newName: String?
    var newNote: String?
    var isFavourite: Bool?
    var isMuted: Bool?
    var isBlocked: Bool?
}

protocol ContactsServiceProtocol {
    func loadLocalContacts() async throws -> [Contact]
    func syncContacts() async throws
    func isContactExistsLocally(userId: String) async throws -> Bool
    func createContact(params: CreateContactParams) async throws -> Contact
    func updateContact(params: UpdateContactParams) async throws -> Contact
    func deleteContact(id: String) async throws -> Void
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
    
    func createContact(params: CreateContactParams) async throws -> Contact {
        let requestDto = CreateContactRequestDTO(
            contactUserId: params.userId,
            alias: params.name,
            isFavourite: params.isAddingToFavourites
        )
        let createdContactDto = try await remoteDataSource.createContact(
            dto: requestDto,
        )
        try await localDataSource.upsertContact(createdContactDto)
        return createdContactDto.toDomain()
    }
    
    func updateContact(params: UpdateContactParams) async throws -> Contact {
        let requestDto = UpdateContactRequestDTO(
            alias: params.newName,
            note: params.newNote,
            isFavourite: params.isFavourite,
            isBlocked: params.isBlocked,
            isMuted: params.isMuted,
        )
        let updatedContactDto = try await remoteDataSource.updateContact(
            id: params.id,
            dto: requestDto,
        )
        try await localDataSource.upsertContact(updatedContactDto)
        return updatedContactDto.toDomain()
    }
    
    func deleteContact(id: String) async throws {
        try await remoteDataSource.deleteContact(id: id)
        try await localDataSource.deleteContact(id: id)
    }
}



