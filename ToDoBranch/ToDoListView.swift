//
//  ToDoListView.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/7/25.
//

import SwiftUI

struct ToDoItem: Identifiable {
    let id = UUID()
    var name: String
    var completed: Bool
}

struct ToDoListView: View {
    @Bindable var viewModel: ToDoListViewModel
    @FocusState private var focusedID: UUID?

    var body: some View {
        List {
            ForEach($viewModel.toDos) { $todo in
                Button {
                    withAnimation {
                        todo.completed.toggle()
                    }
                } label: {
                    Label {
                        TextField("", text: $todo.name)
                            .focused($focusedID, equals: todo.id)
                    } icon: {
                        Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    }
                }
            }
            .onDelete { indexSet in
                viewModel.onDelete(indexSet)
            }
        }
        .listStyle(.plain)
        .navigationTitle("To-Do List")
        .scrollDismissesKeyboard(.immediately)
        .fontDesign(.rounded)
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

#Preview {
    NavigationStack {
        ToDoListView(viewModel: ToDoListViewModel())
    }
}
