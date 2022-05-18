//
//  NetworkResponseInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// A response interceptor, which will be executed after the backend's response has been received.
public protocol NetworkResponseInterceptor {
    /// Intercepts a response as received by the backend. Data may be mutated on the original response.
    /// - Parameter response: The response, on which mutation is possible.
    func intercept(response: inout HTTPResponse) throws
}
