//
//  SyncStateService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation
import CoreData

protocol SyncStateServiceProtocol {
    func getLastSyncAt(key: String) async throws -> Date?
    func setLastSyncAt(key: String, date: Date) async throws
}

class SyncStateService: SyncStateServiceProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getLastSyncAt(key: String) async throws -> Date? {
        try await context.perform {
            let request: NSFetchRequest<SyncStateEntity> = SyncStateEntity.fetchRequest()
            request.predicate = NSPredicate(format: "key == %@", key)
            request.fetchLimit = 1
            
            let entity = try self.context.fetch(request).first
            return entity?.lastSyncAt
        }
    }
    
    func setLastSyncAt(key: String, date: Date = Date()) async throws {
        try await context.perform {
            let request: NSFetchRequest<SyncStateEntity> = SyncStateEntity.fetchRequest()
            request.predicate = NSPredicate(format: "key == %@", key)
            request.fetchLimit = 1
            
            let entity = try self.context.fetch(request).first ?? SyncStateEntity(context: self.context)
            
            entity.key = key
            entity.lastSyncAt = date
            
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }
}
