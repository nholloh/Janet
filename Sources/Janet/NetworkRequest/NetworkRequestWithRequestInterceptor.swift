//
//  NetworkRequestWithRequestInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

public protocol NetworkRequestWithRequestInterceptor: NetworkRequest {
    var requestInterceptor: NetworkRequestInterceptor { get }
}
