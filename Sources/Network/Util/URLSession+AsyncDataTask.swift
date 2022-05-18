//
//  URLSession+AsyncDataTask.swift
//
//
//  Created by Niklas Holloh on 12.05.22.
//

import Foundation

extension URLError.Code {
    /// The request has no url response, although it was successful (error == nil).
    static let requestHasNoURLResponse: URLError.Code = .init(rawValue: 1000)
}

extension URLSession {

    func data(request: URLRequest) async throws -> (data: Data?, response: URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let dataTask = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let response = response else {
                    continuation.resume(throwing: URLError(.requestHasNoURLResponse))
                    return
                }

                continuation.resume(returning: (data: data, response: response))
            }
            dataTask.resume()
        }
    }

}
