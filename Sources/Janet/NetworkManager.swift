//
//  NetworkManager.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// Used to convert `NetworkRequest`configurations to `URLRequests` and
/// send them through `URLSession`.
public final class NetworkManager: Networking {

    /// Errors that can occur when using the NetworkManager.
    public enum Error: Swift.Error {
        case invalidURL(URL)
        case invalidURLComponents(URLComponents)
        case invalidQueryObject
        case responseIsNoHTTPURLResponse
        case errorStatusCode(code: Int, response: HTTPResponse)
        case responseHasNoData
    }

    // MARK: - Public Configuration
    /// Gets or sets the default encoder for HTTP bodies. Default is `JSONEncoder`.
    public var httpBodyEncoder: DataEncoding = JSONEncoder()

    /// Gets or sets the default decoder for HTTP bodies. Default is `JSONDecoder`.
    public var httpBodyDecoder: DataDecoding = JSONDecoder()

    /// Gets or sets the default request interceptor, which is used to inspect or mutate a request
    /// after its construction (URLRequest), right before it is passed to `URLSession` for sending it
    /// to a web host. Default is empty.
    public var requestInterceptor: NetworkRequestInterceptor = ClosureRequestInterceptor { _ in }

    /// Gets or sets the default response interceptor, which is used to inspect or mutate a response
    /// after receiving it from `URLSession`, before its data may be decoded and passed back to
    /// the call site. Default is `ValidateHTTPStatusResponseInterceptor.default`.
    public var responseInterceptor: NetworkResponseInterceptor = ValidateHTTPStatusResponseInterceptor.default

    /// Creates a new instance of NetworkManager.
    public init() { }

    // MARK: - Internal properties
    let urlSession: URLSession = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil)
}

// MARK: - NetworkRequestWithQuery
extension NetworkManager {
    func queryItems(request: any NetworkRequest) throws -> [URLQueryItem]? {
        guard let requestWithQuery = request as? NetworkRequestWithQuery else {
            return nil
        }

        guard let queryItemsDictionary = requestWithQuery.query.dictionaryRepresentation else {
            throw Error.invalidQueryObject
        }

        return queryItemsDictionary.reduce(into: [URLQueryItem]()) { queryItems, keyValuePair in
            queryItems.append(URLQueryItem(name: keyValuePair.key, value: "\(keyValuePair.value)"))
        }
    }
}

// MARK: NetworkRequestWithBody
extension NetworkManager {
    func body<R: NetworkRequestWithBody>(request: R) throws -> Data? {
        let encoder = request.httpBodyEncoder ?? httpBodyEncoder
        return try encoder.encode(request.body)
    }
}

// MARK: - NetworkRequestWithRequestInterceptor
extension NetworkManager {
    func intercept<R>(request: R, httpRequest: inout HTTPRequest) async throws {
        guard let requestWithCustomInterceptor = request as? NetworkRequestWithRequestInterceptor else {
            try await requestInterceptor.intercept(request: &httpRequest)
            return
        }

        try await requestWithCustomInterceptor.requestInterceptor
            .chain(before: requestInterceptor)
            .intercept(request: &httpRequest)
    }
}

// MARK: - NetworkRequestWithResponseInterceptor
extension NetworkManager {
    func intercept<R>(request: R, httpResponse: inout HTTPResponse) async throws -> NetworkResponseInterceptorResult {
        guard let requestWithCustomInterceptor = request as? NetworkRequestWithResponseInterceptor else {
            return try await responseInterceptor.intercept(response: &httpResponse)
        }

        return try await requestWithCustomInterceptor.responseInterceptor
            .chain(after: responseInterceptor)
            .intercept(response: &httpResponse)
    }
}

// MARK: - NetworkRequestWithResponse
extension NetworkManager {
    func decodeResponse<R: NetworkRequestWithResponse>(request: R, httpResponse: HTTPResponse) throws -> R.ResponseType {
        guard let data = httpResponse.data else {
            throw Error.responseHasNoData
        }

        let decoder = request.httpBodyDecoder ?? self.httpBodyDecoder
        return try decoder.decode(R.ResponseType.self, from: data)
    }
}
