//
//  Helpers.swift
//  ToDoBranch
//
//  Created by Jon Duenas on 5/10/25.
//

import SwiftUI

extension Optional where Wrapped == String {
    var emptyIfNil: String {
        get { self ?? "" }
        set { self = newValue }
    }
}
