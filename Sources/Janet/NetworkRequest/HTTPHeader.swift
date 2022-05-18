//
//  HTTPHeader.swift
//  
//
//  Created by Niklas Holloh on 24.04.22.
//

import Foundation

/// Represents an HTTPHeader key.
public struct HTTPHeader: Hashable, ExpressibleByStringLiteral {

    /// The raw string key.
    public let headerKey: String

    /// Creates a new instance of `HTTPHeader`.
    /// - Parameter headerKey: The raw string header key.
    public init(_ headerKey: String) {
        self.headerKey = headerKey
    }

    /// Creates a new instance of `HTTPHeader`.
    /// - Parameter value: The raw string header key.
    public init(stringLiteral value: String) {
        headerKey = value
    }
}
