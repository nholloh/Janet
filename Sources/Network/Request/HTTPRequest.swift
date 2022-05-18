//
//  HTTPRequest.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// An internal representation of the HTTPRequest which may or may not have been sent.
public struct HTTPRequest {

    /// The unique ID of the request.
    public let uuid = UUID()

    /// The underlying URLRequest.
    public var urlRequest: URLRequest

}
