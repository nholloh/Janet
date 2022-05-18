//
//  ClosureResponseInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// A response interceptor, which receives a closure to process the HTTPResponse.
public class ClosureResponseInterceptor: NetworkResponseInterceptor {
    private let closure: (inout HTTPResponse) throws -> Void

    /// Creates a response interceptor, which receives a closure to process the HTTPResponse.
    /// - Parameter closure: The closure which receives and mutates the HTTPResponse.
    public init(_ closure: @escaping (inout HTTPResponse) throws -> Void) {
        self.closure = closure
    }

    public func intercept(response: inout HTTPResponse) throws {
        try closure(&response)
    }
}