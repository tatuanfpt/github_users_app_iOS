import XCTest
import CoreData
@testable import GithubUserApp

class TestCoreDataStack: XCTestCase, CoreDataStackProtocol {
    private var persistentContainer: NSPersistentContainer!
    private var managedObjectContext: NSManagedObjectContext!
    
    var context: NSManagedObjectContext {
        return managedObjectContext
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create an in-memory persistent store
        persistentContainer = NSPersistentContainer(name: "GitHubUsersApp")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        let expectation = XCTestExpectation(description: "Load persistent store")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                XCTFail("Failed to load persistent store: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        managedObjectContext = persistentContainer.viewContext
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    override func tearDownWithError() throws {
        // Clean up the context by deleting all objects
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CachedUser")
        let objects = try managedObjectContext.fetch(fetchRequest)
        for object in objects {
            managedObjectContext.delete(object as! NSManagedObject)
        }
        try managedObjectContext.save()
        
        managedObjectContext = nil
        persistentContainer = nil
        try super.tearDownWithError()
    }
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                XCTFail("Failed to save context: \(error)")
            }
        }
    }
    
    func createTestUser(id: Int = 1, login: String = "testuser", avatarUrl: String = "https://test.com/avatar") -> CachedUser {
        let user = CachedUser(context: managedObjectContext)
        user.id = Int64(id)
        user.login = login
        user.avatarUrl = avatarUrl
        user.htmlUrl = "https://test.com/user"
        return user
    }
} 