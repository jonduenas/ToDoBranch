//
//  Fetchable.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/10/25.
//

import Foundation

protocol Fetchable: Codable, Sendable {
    static var url: URL { get }
    static var urlRequest: URLRequest { get }
}
