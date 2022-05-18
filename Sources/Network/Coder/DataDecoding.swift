//
//  DataDecoding.swift
//  
//
//  Created by Niklas Holloh on 18.05.22.
//

import Foundation

public protocol DataDecoding {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}
