//
//  DemoToDo.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/10/25.
//

import Foundation

//{
//    "userId": 1,
//    "id": 2,
//    "title": "quis ut nam facilis et officia qui",
//    "completed": false
//}

struct DemoToDo {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
}

extension DemoToDo: Fetchable {
    static var url: URL {
        URL(string: "https://jsonplaceholder.typicode.com/todos")!
    }

    static var urlRequest: URLRequest {
        URLRequest(url: url)
    }
}
