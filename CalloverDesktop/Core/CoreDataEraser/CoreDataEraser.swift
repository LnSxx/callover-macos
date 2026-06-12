//
//  CoreDataEraser.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.06.26.
//

import CoreData

protocol CoreDataEraserProtocol {
    func eraseUserData() async throws
}

final class CoreDataEraser: CoreDataEraserProtocol {
    private let persistentContainer: NSPersistentContainer
    
    private let userDataEntityNames = [
        "ContactEntity",
        "CallLogEntity",
        "NotificationEntity",
        "SyncStateEntity"
    ]
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func eraseUserData() async throws {
        let context = persistentContainer.newBackgroundContext()
        
        try await context.perform {
            for entityName in self.userDataEntityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
                    entityName: entityName
                )
                
                let deleteRequest = NSBatchDeleteRequest(
                    fetchRequest: fetchRequest
                )
                
                deleteRequest.resultType = .resultTypeObjectIDs
                
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [
                            NSDeletedObjectsKey: objectIDs
                        ],
                        into: [
                            self.persistentContainer.viewContext
                        ]
                    )
                }
            }
        }
    }
}

final class MockCoreDataEraser: CoreDataEraserProtocol {
    func eraseUserData() async throws {}
}
