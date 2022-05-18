//
//  LogRequestInterceptor.swift
//  
//
//  Created by Niklas Holloh on 12.05.22.
//

import Foundation

public class LogRequestInterceptor: NetworkRequestInterceptor {
    private let log: (String) -> Void

    public init(log: @escaping (String) -> Void) {
        self.log = log
    }

    public func intercept(request: inout HTTPRequest) {
        var stringEncodedBody: String?
        if let body = request.urlRequest.httpBody {
            stringEncodedBody = String(data: body, encoding: .utf8)
        }

        let message = """

        📤 Sending URL request:
        - ID: \(request.uuid)
        - URL: \(request.urlRequest.url?.absoluteString ?? "nil")
        - Method: \(request.urlRequest.httpMethod ?? "nil")
        - Headers:
          \(request.urlRequest.allHTTPHeaderFields.debugDescription)
        - Body:
          \(stringEncodedBody ?? "nil")
        """

        log(message)
    }
}
