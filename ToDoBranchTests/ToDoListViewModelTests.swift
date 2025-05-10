//
//  ToDoListViewModelTests.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/10/25.
//


import Testing
@testable import ToDoBranch
import Foundation

@MainActor
struct ToDoListViewModelTests {

    @Test func newItemButtonTappedCreatesNewItemAndReturnsID() async throws {
        let viewModel = ToDoListViewModel()
        let initialCount = viewModel.toDos.count
        let newItemID = viewModel.newItemButtonTapped()

        // Check if the new item is added to the list
        #expect(viewModel.toDos.count == initialCount + 1)

        // Check if the new item has a unique ID
        #expect(viewModel.toDos.last?.id == newItemID)
    }

    @Test func onDeleteRemovesItemFromList() async throws {
        let viewModel = ToDoListViewModel()
        let initialCount = viewModel.toDos.count

        // Delete the first item
        viewModel.onDelete(IndexSet(integer: 0))

        // Check if the item was removed
        #expect(viewModel.toDos.count == initialCount - 1)
    }

}
