//
//  NetworkRequest.swift
//  
//
//  Created by Niklas Holloh on 24.04.22.
//

import Foundation

public protocol NetworkRequest {
    var method: HTTPMethod { get }

    var endpoint: URL { get }

    var headers: [HTTPHeader: String] { get }
}

public extension NetworkRequest {
    var headers: [HTTPHeader: String] { [:] }
}
