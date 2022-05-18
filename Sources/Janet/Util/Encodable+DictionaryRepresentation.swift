//
//  Encodable+dictionaryRepresentation.swift
//
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

extension Encodable {
    /// Returns a dictionary representation of an `Encodable` object or nil,
    /// if the type is incompatible with JSON.
    var dictionaryRepresentation: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
