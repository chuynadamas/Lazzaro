//
//  File.swift
//  File
//
//  Created by chuynadamas on 9/6/21.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    subscript(safeKey key: Key) -> Value {
        get {
            return self[key] ?? ""
        }
    }
}
