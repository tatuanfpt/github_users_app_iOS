//
//  CoreDataStack.swift
//  GithubUserApp
//
//  Created by TuanTa on 24/4/25.
//


import CoreData

/// Manages CoreData stack for persistent storage
class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHubUsersApp")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("Failed to load CoreData stack: \(error)")
                print("Store Description: \(storeDescription)")
                fatalError("Failed to load CoreData stack: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save CoreData context: \(error)")
            }
        }
    }
    
    
}
