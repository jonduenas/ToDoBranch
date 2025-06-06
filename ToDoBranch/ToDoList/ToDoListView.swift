//
//  ToDoListView.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/7/25.
//

import SwiftUI

struct ToDoContainerView: View {
    let viewModel: ToDoListViewModel

    @State private var isShowingDemo = false

    var body: some View {
        NavigationStack {
            ToDoListView(viewModel: viewModel)
                .navigationTitle("To-Do List")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Try Demo") {
                            isShowingDemo.toggle()
                        }
                    }
                }
                .fullScreenCover(isPresented: $isShowingDemo) {
                    DemoView()
                }
        }
        .fontDesign(.rounded)
    }
}


struct ToDoListView: View {
    let viewModel: ToDoListViewModel
    @FocusState private var focusedID: ToDo.ID?

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.toDos) { todo in
                    ToDoListItemView(todo: todo) {
                        viewModel.onChanged($0)
                    }
                    .id(todo.id)
                    .focused($focusedID, equals: todo.id)
                }
                .onDelete { indexSet in
                    viewModel.onDelete(indexSet)
                }
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
            .animation(.default, value: viewModel.toDos)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if focusedID != nil {
                        Button("Done") {
                            withAnimation { focusedID = nil }
                        }
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation {
                            // New ToDo is added at the bottom of the uncompleted items, but above the completed ones
                            if let lastUncompletedID = viewModel.toDos.last(where: { !$0.completed })?.id {
                                proxy.scrollTo(lastUncompletedID)
                            } else if let firstCompletedID = viewModel.toDos.first(where: { $0.completed })?.id {
                                proxy.scrollTo(firstCompletedID)
                            }

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
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .task {
            await viewModel.onAppearTask()
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

struct DemoView: View {
    @State private var viewModel = ToDoListViewModel(
        repository: ToDoRepository(mode: .demo)
    )

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ToDoListView(viewModel: viewModel)
                .navigationTitle("Demo")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") { dismiss() }
                    }
                }
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
        }
    }
}

#Preview {
    ToDoContainerView(
        viewModel: ToDoListViewModel(
            repository: ToDoRepository(
                mode: .live(.preview)
            )
        )
    )
}
