//
//  NetworkRequestWithResponseInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

public protocol NetworkRequestWithResponseInterceptor: NetworkRequest {
    var responseInterceptor: NetworkResponseInterceptor { get }
}
