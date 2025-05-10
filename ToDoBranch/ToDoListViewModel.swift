//
//  ToDoListViewModel.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/10/25.
//

import Foundation

@Observable
@MainActor
final class ToDoListViewModel {
    var toDos: [ToDoItem] = [
        ToDoItem(name: "Buy groceries", completed: false),
        ToDoItem(name: "Walk the dog", completed: true),
        ToDoItem(name: "Finish homework", completed: false)
    ]

    func newItemButtonTapped() -> UUID {
        let new = ToDoItem(name: "", completed: false)
        toDos.append(new)
        return new.id
    }

    func onDelete(_ indexSet: IndexSet) {
        toDos.remove(atOffsets: indexSet)
    }
}
