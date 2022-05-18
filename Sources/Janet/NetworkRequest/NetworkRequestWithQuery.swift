//
//  NetworkRequestWithQuery.swift
//  
//
//  Created by Niklas Holloh on 24.04.22.
//

import Foundation

public protocol NetworkRequestWithQuery: NetworkRequest {
    var query: Encodable { get }
}
