//
//  ToDoListView.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/7/25.
//

import SwiftUI

struct ToDoListView: View {
    let viewModel: ToDoListViewModel
    @FocusState private var focusedID: ToDo.ID?

    var body: some View {
        List {
            ForEach(viewModel.toDos) { todo in
                ToDoListItemView(todo: todo) {
                    viewModel.onChanged($0)
                }
                .focused($focusedID, equals: todo.id)
            }
            .onDelete { indexSet in
                viewModel.onDelete(indexSet)
            }
        }
        .listStyle(.plain)
        .navigationTitle("To-Do List")
        .scrollDismissesKeyboard(.immediately)
        .fontDesign(.rounded)
        .animation(.default, value: viewModel.toDos)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    withAnimation {
                        focusedID = viewModel.newItemButtonTapped()
                    }
                } label: {
                    Label("New Item", systemImage: "plus.circle.fill")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)
                .labelStyle(.titleAndIcon)
            }
        }
    }
}

struct ToDoListItemView: View {
    @ObservedObject var todo: ToDo
    let onChange: (ToDo) -> Void

    init(todo: ToDo, onChange: @escaping (ToDo) -> Void) {
        self.todo = todo
        self.onChange = onChange
    }

    var body: some View {
        Label {
            TextField(
                "Name",
                text: $todo.name.emptyIfNil,
                prompt: Text("")
            )
        } icon: {
            Toggle(isOn: $todo.completed) {
                Label(
                    "Completed",
                    systemImage: todo.completed ? "checkmark.circle.fill" : "circle"
                )
            }
            .toggleStyle(.button)
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
        }
        .onReceive(todo.objectWillChange) { _ in
            onChange(todo)
        }
    }
}


#Preview {
    NavigationStack {
        ToDoListView(
            viewModel: ToDoListViewModel(
                repository: ToDoRepository(
                    persistenceController: .preview
                )
            )
        )
    }
}
