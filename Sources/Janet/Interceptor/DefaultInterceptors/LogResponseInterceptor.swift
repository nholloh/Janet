//
//  LogResponseInterceptor.swift
//  
//
//  Created by Niklas Holloh on 12.05.22.
//

import Foundation

public class LogResponseInterceptor: NetworkResponseInterceptor {
    private let log: (String) -> Void

    public init(log: @escaping (String) -> Void) {
        self.log = log
    }

    public func intercept(response: inout HTTPResponse) throws {
        var stringEncodedBody: String?
        if let body = response.data {
            stringEncodedBody = String(data: body, encoding: .utf8)
        }

        let message = """

        📥 Received URL response:
        - ID: \(response.request.uuid)
        - URL: \(response.request.urlRequest.url?.absoluteString ?? "nil")
        - Method: \(response.request.urlRequest.httpMethod ?? "nil")
        - Headers:
          \(response.urlResponse.allHeaderFields.debugDescription)
        - Body:
          \(stringEncodedBody ?? "nil")
        """

        log(message)
    }
}
