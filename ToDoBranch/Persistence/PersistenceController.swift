//
//  PersistenceController.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/6/25.
//

@preconcurrency import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newToDo = ToDo(context: viewContext)
            newToDo.name = "Sample ToDo"
            newToDo.completed = [true, false].randomElement()!
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    static let managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle.main

        guard let url = bundle.url(forResource: "ToDoBranch", withExtension: "momd") else {
            fatalError("Failed to locate momd file for xcdatamodeld")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for xcdatamodeld")
        }

        return model
    }()

    static var demo: PersistenceController { PersistenceController(inMemory: true) }

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ToDoBranch", managedObjectModel: Self.managedObjectModel)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
