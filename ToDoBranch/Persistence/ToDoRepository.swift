//
//  ToDoRepository.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/7/25.
//

import Foundation
import CoreData

@MainActor
@Observable
final class ToDoRepository {
    var todos: [ToDo] = []

    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    private let resultsController: NSFetchedResultsController<ToDo>
    private let observer: FetchedResultsObserver<ToDo>

    init(
        filter: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(keyPath: \ToDo.completed, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.dateCreated, ascending: true),
        ],
        persistenceController: PersistenceController = .shared
    ) {
        self.persistenceController = persistenceController
        self.context = persistenceController.container.viewContext

        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = filter
        fetchRequest.sortDescriptors = sortDescriptors

        self.resultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        self.observer = FetchedResultsObserver(controller: resultsController)
        observer.didChange = { [weak self] in
            self?.didChange()
        }

        try? self.resultsController.performFetch()
        didChange()
    }

    @discardableResult
    func addToDo(name: String = "") throws -> ToDo {
        let newToDo = ToDo(context: context)
        newToDo.name = name
        newToDo.completed = false
        newToDo.dateCreated = Date()

        try context.save()
        return newToDo
    }

    func delete(_ toDo: ToDo) throws {
        context.delete(toDo)
        try context.save()
    }

    func update(_ toDo: ToDo) throws {
        if context.hasChanges {
            try context.save()
        }
    }

    private func didChange() {
        if let objects = resultsController.fetchedObjects {
            todos = objects
        }
    }
}

private final class FetchedResultsObserver<Result: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    var didChange: (() -> Void)?

    init(controller: NSFetchedResultsController<Result>) {
        super.init()
        controller.delegate = self
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChange?()
    }
}
