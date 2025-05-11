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
    enum Mode {
        case live(PersistenceController)
        case demo
    }

    var todos: [ToDo] = []

    private let context: NSManagedObjectContext
    private let resultsController: NSFetchedResultsController<ToDo>
    private let observer: FetchedResultsObserver<ToDo>
    private let demoDataService: any FetchableServicing<DemoToDo>
    private let mode: Mode

    init(
        filter: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(keyPath: \ToDo.completed, ascending: true),
            NSSortDescriptor(keyPath: \ToDo.dateCreated, ascending: true),
        ],
        mode: Mode = .live(PersistenceController.shared),
        demoDataService: any FetchableServicing<DemoToDo> = FetchableService<DemoToDo>()
    ) {
        self.mode = mode

        let persistenceController = switch mode {
        case .live(let persistenceController):
            persistenceController
        case .demo:
            PersistenceController(inMemory: true)
        }

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
        self.demoDataService = demoDataService

        observer.didChange = { [weak self] in
            self?.didChange()
        }
    }

    func getToDo(with objectID: NSManagedObjectID) -> ToDo? {
        do {
            return try context.existingObject(with: objectID) as? ToDo
        } catch {
            print("Error fetching ToDo with objectID \(objectID): \(error)")
            return nil
        }
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

    func loadData() async throws {
        switch mode {
        case .live:
            try loadFromStore()
        case .demo:
            try await loadDemoData()
        }
    }

    private func loadFromStore() throws {
        try self.resultsController.performFetch()
        didChange()
    }

    private func loadDemoData() async throws {
        let demoToDos = try await demoDataService.fetch()
        for demoToDo in demoToDos {
            let newToDo = ToDo(context: context)
            newToDo.name = demoToDo.title
            newToDo.completed = demoToDo.completed
            newToDo.dateCreated = Date()
        }
        try context.save()
        try loadFromStore()
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
