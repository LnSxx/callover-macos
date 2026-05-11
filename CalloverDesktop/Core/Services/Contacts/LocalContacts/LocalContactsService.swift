//
//  LocalContactsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation
import CoreData

protocol LocalContactsServiceProtocol {
    func getContactByUserId(userId: String) async throws -> Contact?
    func fetchContacts() async throws -> [Contact]
    func upsertContacts(_ contacts: [ContactDTO]) async throws
    func upsertContact(_ contact: ContactDTO) async throws
    func deleteContact(id: String) async throws
    func deleteContacts(ids: [String]) async throws
    func eraseContacts() async throws
}

class LocalContactsService: LocalContactsServiceProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getContactByUserId(userId: String) async throws -> Contact? {
        try await context.perform {
            let request: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
            request.predicate = NSPredicate(format: "contactUserId == %@", userId)
            request.fetchLimit = 1
            
            return try self.context.fetch(request).first?.toDomain()
        }
    }
    
    func fetchContacts() async throws -> [Contact] {
        try await context.perform {
            let request: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "alias", ascending: false)
            ]
            
            let entities = try self.context.fetch(request)
            
            return entities.map { $0.toDomain() }
        }
    }
    
    func upsertContacts(_ contacts: [ContactDTO]) async throws {
        try await context.perform {
            for dto in contacts {
                try self.upsert(dto)
            }
            
            try self.context.save()
        }
    }
    
    func upsertContact(_ contact: ContactDTO) async throws {
        try await context.perform {
            try self.upsert(contact)
            try self.context.save()
        }
    }
    
    func deleteContact(id: String) async throws {
        try await context.perform {
            let request: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            
            if let entity = try self.context.fetch(request).first {
                self.context.delete(entity)
                try self.context.save()
            }
        }
    }
    
    func deleteContacts(ids: [String]) async throws {
        guard !ids.isEmpty else { return }
        
        try await context.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = ContactEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids)
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            let result = try self.context.execute(deleteRequest) as? NSBatchDeleteResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.context])
            }
        }
    }
    
    func eraseContacts() async throws {
        try await context.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = ContactEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try self.context.execute(deleteRequest)
        }
    }
    
    private func upsert(_ dto: ContactDTO) throws {
        let request: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dto.id)
        request.fetchLimit = 1
        
        let entity = try context.fetch(request).first ?? ContactEntity(context: context)
        
        entity.id = dto.id
        entity.ownerId = dto.ownerId
        entity.contactUserId = dto.contactUserId
        entity.alias = dto.alias
        entity.note = dto.note
        entity.isFavourite = dto.isFavourite
        entity.isBlocked = dto.isBlocked
        entity.isMuted = dto.isMuted
        entity.createdAt = ISO8601DateFormatter().date(from: dto.createdAt) ?? Date()
        entity.updatedAt = ISO8601DateFormatter().date(from: dto.updatedAt) ?? Date()
    }
}
