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
    @State private var toDos: [ToDoItem] = [
        ToDoItem(name: "", completed: false),
        ToDoItem(name: "Buy groceries", completed: false),
        ToDoItem(name: "Walk the dog", completed: true),
        ToDoItem(name: "Finish homework", completed: false)
    ]

    @FocusState private var focusedID: UUID?

    var body: some View {
        List {
            ForEach($toDos) { $todo in
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
                toDos.remove(atOffsets: indexSet)
            }
        }
        .listStyle(.plain)
        .navigationTitle("To-Do List")
        .fontDesign(.rounded)
        .safeAreaInset(edge: .bottom) {
            if focusedID == nil {
                Button {
                    withAnimation {
                        let new = ToDoItem(name: "", completed: false)
                        toDos.append(new)
                        focusedID = new.id
                    }
                } label: {
                    Label("New Item", systemImage: "plus.circle.fill")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .imageScale(.large)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ToDoListView()
    }
}
