//
//  Persistence.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.04.26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        for index in 0..<10 {
            let contact = ContactEntity(context: context)
            contact.id = UUID().uuidString
            contact.ownerId = "preview-owner-id"
            contact.contactUserId = "preview-user-\(index)"
            contact.alias = "Contact \(index + 1)"
            contact.note = "Preview note"
            contact.isFavourite = index % 2 == 0
            contact.isBlocked = false
            contact.isMuted = false
            contact.createdAt = Date()
            contact.updatedAt = Date()
        }
        
        let syncState = SyncStateEntity(context: context)
        syncState.key = "contacts"
        syncState.lastSyncAt = Date()
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("Unresolved Core Data preview error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CalloverDesktop")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        return context
    }
    
    func saveViewContext() {
        let context = container.viewContext
        
        guard context.hasChanges else {
            return
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("Failed to save viewContext \(nsError), \(nsError.userInfo)")
        }
    }
}
