//
//  NetworkResponseInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// A result returned by the network response interceptor.
public enum NetworkResponseInterceptorResult {

    /// Perform default handling. Has the lowest precedence. Will be overriden by all other cases.
    case defaultHandling

    /// Retry the request after finishing interceptions.
    case retryRequest

    func combine(with other: NetworkResponseInterceptorResult) -> NetworkResponseInterceptorResult {
        switch (self, other) {
        case (.defaultHandling, .retryRequest): return .retryRequest
        case (.retryRequest, .defaultHandling): return .retryRequest
        default: return self
        }
    }
}

/// A response interceptor, which will be executed after the backend's response has been received.
public protocol NetworkResponseInterceptor {
    /// Intercepts a response as received by the backend. Data may be mutated on the original response.
    /// - Parameter response: The response, on which mutation is possible.
    func intercept(response: inout HTTPResponse) async throws -> NetworkResponseInterceptorResult
}
