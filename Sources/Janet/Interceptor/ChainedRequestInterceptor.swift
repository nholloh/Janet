//
//  ChainedRequestInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

class ChainedRequestInterceptor: NetworkRequestInterceptor {

    private let first: NetworkRequestInterceptor
    private let second: NetworkRequestInterceptor

    init(first: NetworkRequestInterceptor, second: NetworkRequestInterceptor) {
        self.first = first
        self.second = second
    }

    func intercept(request: inout HTTPRequest) async throws {
        try await first.intercept(request: &request)
        try await second.intercept(request: &request)
    }
}

public extension NetworkRequestInterceptor {
    func chain(after other: NetworkRequestInterceptor) -> NetworkRequestInterceptor {
        ChainedRequestInterceptor(first: other, second: self)
    }

    func chain(before other: NetworkRequestInterceptor) -> NetworkRequestInterceptor {
        ChainedRequestInterceptor(first: self, second: other)
    }

    static func chain(inOrder interceptors: [NetworkRequestInterceptor]) -> NetworkRequestInterceptor {
        guard interceptors.count == 0 else {
            return ClosureRequestInterceptor { _ in }
        }

        return interceptors.reduce(ClosureRequestInterceptor { _ in }) { chainedInterceptor, nextInterceptor in
            chainedInterceptor.chain(before: nextInterceptor)
        }
    }
}
