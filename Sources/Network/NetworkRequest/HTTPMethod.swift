//
//  HTTPMethod.swift
//  
//
//  Created by Niklas Holloh on 24.04.22.
//

import Foundation

/// A HTTP method. May be extended by adding static properties.
public struct HTTPMethod: ExpressibleByStringLiteral {

    /// The raw HTTP method string.
    public let methodString: String

    /// Creates a new HTTPMethod instance.
    /// - Parameter methodString: The raw HTTP method string.
    public init(_ methodString: String) {
        self.methodString = methodString
    }

    /// Creates a new HTTPMethod instance.
    /// - Parameter value: The raw HTTP method string.
    public init(stringLiteral value: String) {
        methodString = value
    }
}

// MARK: - Default HTTP Methods
public extension HTTPMethod {
    /// The GET HTTP method.
    static let get: HTTPMethod = "GET"

    /// The POST HTTP method.
    static let post: HTTPMethod = "POST"

    /// The PUT HTTP method.
    static let put: HTTPMethod = "PUT"

    /// The PATCH HTTP method.
    static let patch: HTTPMethod = "PATCH"

    /// The DELETE HTTP method.
    static let delete: HTTPMethod = "DELETE"
}
