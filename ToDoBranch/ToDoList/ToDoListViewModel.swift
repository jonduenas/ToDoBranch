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
    var toDos: [ToDo] {
        repository.todos
    }

    private let repository: ToDoRepository

    init(repository: ToDoRepository) {
        self.repository = repository
    }

    func newItemButtonTapped() -> ToDo.ID? {
        do {
            let new = try repository.addToDo()
            return new.id
        } catch {
            print("Error adding new item: \(error)")
            return nil
        }
    }

    func onChanged(_ todo: ToDo) {
        do {
            try repository.update(todo)
        } catch {
            print("Error updating item: \(error)")
        }
    }

    func onDelete(_ indexSet: IndexSet) {
        for index in indexSet {
            let toDo = toDos[index]
            do {
                try repository.delete(toDo)
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }
}
