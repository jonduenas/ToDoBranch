//
//  ToDoRepository.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/7/25.
//

import Foundation
import CoreData

final class ToDoRepository {
    private let persistenceController: PersistenceController

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
}
