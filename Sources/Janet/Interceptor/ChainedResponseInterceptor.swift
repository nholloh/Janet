//
//  ChainedResponseInterceptor.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

class ChainedResponseInterceptor: NetworkResponseInterceptor {

    private let first: NetworkResponseInterceptor
    private let second: NetworkResponseInterceptor

    init(first: NetworkResponseInterceptor, second: NetworkResponseInterceptor) {
        self.first = first
        self.second = second
    }

    func intercept(response: inout HTTPResponse) async throws -> NetworkResponseInterceptorResult {
        let firstResult = try await first.intercept(response: &response)
        let secondResult = try await second.intercept(response: &response)
        return firstResult.combine(with: secondResult)
    }
}

public extension NetworkResponseInterceptor {
    func chain(after other: NetworkResponseInterceptor) -> NetworkResponseInterceptor {
        ChainedResponseInterceptor(first: other, second: self)
    }

    func chain(before other: NetworkResponseInterceptor) -> NetworkResponseInterceptor {
        ChainedResponseInterceptor(first: self, second: other)
    }

    static func chain(inOrder interceptors: [NetworkResponseInterceptor]) -> NetworkResponseInterceptor {
        guard interceptors.count == 0 else {
            return ClosureResponseInterceptor { _ in return .defaultHandling }
        }

        return interceptors.reduce(ClosureResponseInterceptor { _ in return .defaultHandling }) { chainedInterceptor, nextInterceptor in
            chainedInterceptor.chain(before: nextInterceptor)
        }
    }
}
