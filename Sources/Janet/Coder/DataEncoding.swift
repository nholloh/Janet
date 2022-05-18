//
//  DataEncoding.swift
//  
//
//  Created by Niklas Holloh on 18.05.22.
//

import Foundation

public protocol DataEncoding {
    func encode<T: Encodable>(_ model: T) throws -> Data
}
