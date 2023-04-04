//
//  ClosureResponseInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// A response interceptor, which receives a closure to process the HTTPResponse.
public class ClosureResponseInterceptor: NetworkResponseInterceptor {
    private let closure: (inout HTTPResponse) async throws -> NetworkResponseInterceptorResult

    /// Creates a response interceptor, which receives a closure to process the HTTPResponse.
    /// - Parameter closure: The closure which receives and mutates the HTTPResponse.
    public init(_ closure: @escaping (inout HTTPResponse) async throws -> NetworkResponseInterceptorResult) {
        self.closure = closure
    }

    public func intercept(response: inout HTTPResponse) async throws -> NetworkResponseInterceptorResult {
        return try await closure(&response)
    }
}
