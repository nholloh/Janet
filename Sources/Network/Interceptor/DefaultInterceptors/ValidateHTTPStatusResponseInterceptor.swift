//
//  ValidateHTTPStatusResponseInterceptor.swift
//  
//
//  Created by Niklas Holloh on 17.05.22.
//

import Foundation

public class ValidateHTTPStatusResponseInterceptor: NetworkResponseInterceptor {

    public static let `default` = ValidateHTTPStatusResponseInterceptor()
    public let allowedStatusCodes: Range<Int>

    public init(allowedStatusCodes: Range<Int> = 200..<300) {
        self.allowedStatusCodes = allowedStatusCodes
    }

    public func intercept(response: inout HTTPResponse) throws {
        guard allowedStatusCodes.contains(response.response.statusCode) else {
            throw NetworkManager.Error.errorStatusCode(code: response.response.statusCode, response: response)
        }
    }
}
