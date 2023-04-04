//
//  NetworkRequestInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// A request interceptor, which will be executed before the request is sent to the backend.
public protocol NetworkRequestInterceptor {
    /// Intercepts a request as sent to the backend. Data may be mutated on the original request.
    /// - Parameter request: The request, on which mutation is possible.
    func intercept(request: inout HTTPRequest) async throws
}
