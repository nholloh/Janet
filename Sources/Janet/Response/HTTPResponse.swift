//
//  HTTPResponse.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

public struct HTTPResponse {
    public let request: HTTPRequest

    public var urlResponse: HTTPURLResponse

    public var data: Data?
}
