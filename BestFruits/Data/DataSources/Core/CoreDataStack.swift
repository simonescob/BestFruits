//
//  CoreDataStack.swift
//  BestFruits
//
//  Core Data stack configuration for local storage.
//

import Foundation
import CoreData

/// Core Data stack manager
class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BestFruitsModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // Enable automatic merging and lightweight migration
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving Support
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Background Context
    
    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Batch Operations
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Fetch Request Templates
    
    func fetchFruitEntities() throws -> [FruitEntity] {
        let fetchRequest = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return try context.fetch(fetchRequest)
    }
    
    func fetchFruitEntity(id: UUID) -> FruitEntity? {
        let fetchRequest = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching fruit entity: \(error)")
            return nil
        }
    }
    
    func fetchFavorites() throws -> [FruitEntity] {
        let fetchRequest = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
        fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return try context.fetch(fetchRequest)
    }
}