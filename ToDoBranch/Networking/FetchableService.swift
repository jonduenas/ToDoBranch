//
//  FetchableService.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/10/25.
//

import Foundation

protocol FetchableServicing<Model>: Sendable {
    associatedtype Model: Fetchable
    func fetch() async throws -> [Model]
}

extension FetchableServicing {
    func fetch() async throws -> [Model] {
        let (data, response) = try await URLSession.shared.data(from: Model.url)

        let httpResponse = response as! HTTPURLResponse
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ResponseError.invalidStatusCode(httpResponse.statusCode)
        }

        let decodedResponse = try JSONDecoder().decode([Model].self, from: data)
        return decodedResponse
    }
}

struct FetchableService<Model: Fetchable>: FetchableServicing {
    typealias Model = Model
}

struct FetchableServiceStub<Model: Fetchable>: FetchableServicing {
    typealias Model = Model
    var stubbedResponse: [Model] = []
    
    func fetch() async throws -> [Model] {
        return stubbedResponse
    }
}


enum ResponseError: Error {
    case invalidStatusCode(Int)
    case unknownError(Error)
}
