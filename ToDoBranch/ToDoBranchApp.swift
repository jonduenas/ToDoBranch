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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
