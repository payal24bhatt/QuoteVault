//
//  CoreDataStack.swift
//  
//
//  Created by Payal Bhatt on 10/11/25.
//

import Foundation
import CoreData


final class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}

    private let modelName = "QuoteVault"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { storeDesc, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext() {
        let ctx = context
        if ctx.hasChanges {
            do { try ctx.save() } catch {
                let nserr = error as NSError
                fatalError("Unresolved error \(nserr), \(nserr.userInfo)")
            }
        }
    }
}
