//
//  ToDoListViewModelTests.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/10/25.
//

import Foundation
import Testing

@testable import ToDoBranch

@MainActor
struct ToDoListViewModelTests {
    @Test func newItemButtonTappedCreatesNewItemAndReturnsID() async throws {
        let testPersistence = PersistenceController(inMemory: true)
        let testRepository = ToDoRepository(mode: .live(testPersistence), demoDataService: FetchableServiceStub<DemoToDo>())
        let viewModel = ToDoListViewModel(repository: testRepository)

        await viewModel.onAppearTask()
        let initialCount = viewModel.toDos.count

        let newItemID = viewModel.newItemButtonTapped()

        // Check if the new item is added to the list
        #expect(viewModel.toDos.count == initialCount + 1)

        // Check if the new item has a unique ID
        #expect(viewModel.toDos.last?.id == newItemID)
    }

    @Test func onDeleteRemovesItemFromList() async throws {
        let testPersistence = PersistenceController(inMemory: true)
        let testRepository = ToDoRepository(mode: .live(testPersistence), demoDataService: FetchableServiceStub<DemoToDo>())
        try testRepository.addToDo(name: "Test Item 1")
        let viewModel = ToDoListViewModel(repository: testRepository)

        await viewModel.onAppearTask()
        let initialCount = viewModel.toDos.count
        try #require(initialCount == 1)

        // Delete the first item
        viewModel.onDelete(IndexSet(integer: 0))

        // Check if the item was removed
        #expect(viewModel.toDos.count == initialCount - 1)
    }

    @Test func onChangedUpdatesItem() async throws {
        let testPersistence = PersistenceController(inMemory: true)
        let testRepository = ToDoRepository(mode: .live(testPersistence), demoDataService: FetchableServiceStub<DemoToDo>())
        let viewModel = ToDoListViewModel(repository: testRepository)

        await viewModel.onAppearTask()
        let _ = viewModel.newItemButtonTapped()

        let todo = try #require(viewModel.toDos.first)
        let newName = "Updated Item"
        todo.name = newName
        viewModel.onChanged(todo)

        // Check if the item was updated
        #expect(viewModel.toDos.first?.name == newName)

        // Check if the change was persisted
        let updatedTodo = try #require(testRepository.getToDo(with: todo.objectID))
        #expect(updatedTodo.name == newName)
    }
}
