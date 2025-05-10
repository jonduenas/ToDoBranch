//
//  ToDoBranchApp.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/6/25.
//

import SwiftUI

@main
struct ToDoBranchApp: App {
    let persistenceController = PersistenceController.shared

    @State private var listViewModel = ToDoListViewModel(repository: ToDoRepository())

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ToDoListView(viewModel: listViewModel)
            }
        }
    }
}
