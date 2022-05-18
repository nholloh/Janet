//
//  NetworkRequestWithResponse.swift
//  
//
//  Created by Niklas Holloh on 24.04.22.
//

import Foundation

public protocol NetworkRequestWithResponse: NetworkRequest {
    associatedtype ResponseType: Decodable

    var decoder: JSONDecoder? { get }
}

public extension NetworkRequestWithResponse {
    var decoder: JSONDecoder? { nil }
}
