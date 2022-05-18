//
//  NetworkRequestWithBody.swift
//  
//
//  Created by Niklas Holloh on 24.04.22.
//

import Foundation

public protocol NetworkRequestWithBody: NetworkRequest {
    associatedtype BodyType: Encodable

    var body: BodyType { get }
}
