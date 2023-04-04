//
//  ClosureRequestInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// A request interceptor, which receives a closure to process the HTTPRequest.
public class ClosureRequestInterceptor: NetworkRequestInterceptor {
    private let closure: (inout HTTPRequest) async throws -> Void

    /// Creates a request interceptor, which receives a closure to process the HTTPRequest.
    /// - Parameter closure: The closure which receives and mutates the HTTPRequest.
    public init(_ closure: @escaping (inout HTTPRequest) async throws -> Void) {
        self.closure = closure
    }

    public func intercept(request: inout HTTPRequest) async throws {
        try await closure(&request)
    }
}
