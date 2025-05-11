//
//  ToDoRepositoryTests.swift
//  ToDoBranchTests
//
//  Created by Jon Duenas on 5/11/25.
//

import Foundation
import Testing

@testable import ToDoBranch

@MainActor
struct ToDoRepositoryTests {

    @Test func getToDoReturnsExistingObject() async throws {
        let testPersistence = PersistenceController(inMemory: true)
        let testRepository = ToDoRepository(mode: .live(testPersistence), demoDataService: FetchableServiceStub<DemoToDo>())
        let context = testPersistence.container.viewContext

        let newToDo = ToDo(context: context)
        newToDo.name = "Test ToDo"
        newToDo.completed = false
        newToDo.dateCreated = Date()
        try context.save()

        let fetchedToDo = testRepository.getToDo(with: newToDo.objectID)

        #expect(fetchedToDo != nil)
        #expect(fetchedToDo == newToDo)
    }

    @Test func addToDoSavesNewItemInStore() async throws {
        let testPersistence = PersistenceController(inMemory: true)
        let testRepository = ToDoRepository(mode: .live(testPersistence), demoDataService: FetchableServiceStub<DemoToDo>())

        let newToDo = try testRepository.addToDo(name: "New ToDo")

        #expect(newToDo.name == "New ToDo")
        #expect(newToDo.completed == false)
        #expect(newToDo.dateCreated != nil)

        let fetchedToDo = testRepository.getToDo(with: newToDo.objectID)
        #expect(fetchedToDo == newToDo)
    }

    @Test func deleteRemovesItemFromStore() async throws {
        let testPersistence = PersistenceController(inMemory: true)
        let testRepository = ToDoRepository(mode: .live(testPersistence), demoDataService: FetchableServiceStub<DemoToDo>())

        let newToDo = try testRepository.addToDo(name: "New ToDo")
        try testRepository.delete(newToDo)

        let fetchedToDo = testRepository.getToDo(with: newToDo.objectID)
        #expect(fetchedToDo == nil)
    }

    @Test func updateSavesChangesToItem() async throws {
        let testPersistence = PersistenceController(inMemory: true)
        let testRepository = ToDoRepository(mode: .live(testPersistence), demoDataService: FetchableServiceStub<DemoToDo>())

        let newToDo = try testRepository.addToDo(name: "New ToDo")
        newToDo.name = "Updated ToDo"
        try testRepository.update(newToDo)

        let fetchedToDo = testRepository.getToDo(with: newToDo.objectID)
        #expect(fetchedToDo?.name == "Updated ToDo")
    }

    @Test func loadDataFetchesDataFromStore() async throws {
        let testPersistence = PersistenceController(inMemory: true)
        let testRepository = ToDoRepository(mode: .live(testPersistence), demoDataService: FetchableServiceStub<DemoToDo>())

        let _ = try testRepository.addToDo(name: "New ToDo")
        try await testRepository.loadData()

        #expect(testRepository.todos.count == 1)
    }

    @Test func loadDemoDataAddsDemoItems() async throws {
        var demoDataService = FetchableServiceStub<DemoToDo>()
        demoDataService.stubbedResponse = [
            DemoToDo(
                id: 1,
                userId: 1,
                title: "Demo ToDo 1",
                completed: false
            ),
            DemoToDo(
                id: 2,
                userId: 1,
                title: "Demo ToDo 2",
                completed: true
            )
        ]

        let testRepository = ToDoRepository(mode: .demo, demoDataService: demoDataService)

        try await testRepository.loadData()

        #expect(testRepository.todos.count == 2)
        #expect(testRepository.todos[0].name == "Demo ToDo 1")
        #expect(testRepository.todos[1].name == "Demo ToDo 2")
    }
}
