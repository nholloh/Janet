//
//  NetworkManager+Send.swift
//  
//
//  Created by Niklas Holloh on 12.05.22.
//

import Foundation

public extension NetworkManager {
    /// Sends a preconfigured instance of a `NetworkRequest`, which does not expect a response.
    /// May throw in case the request was not successful.
    /// - Parameter requestConfiguration: The `NetworkRequest` to be sent.
    func send<R: NetworkRequest>(request requestConfiguration: R) async throws {
        let urlRequest = try makeURLRequest(requestConfiguration: requestConfiguration)
        _ = try await getResponse(for: HTTPRequest(urlRequest: urlRequest), requestConfiguration: requestConfiguration)
    }

    /// Sends a preconfigured instance of a `NetworkRequest`, which does not expect a response and
    /// contains a request body. May throw in case the request was not successful.
    /// - Parameter requestConfiguration: The `NetworkRequestWithBody` to be sent.
    func send<R: NetworkRequestWithBody>(request requestConfiguration: R) async throws {
        var urlRequest = try makeURLRequest(requestConfiguration: requestConfiguration)
        urlRequest.httpBody = try body(request: requestConfiguration)
        _ = try await getResponse(for: HTTPRequest(urlRequest: urlRequest), requestConfiguration: requestConfiguration)
    }
}

// With Response
public extension NetworkManager {
    /// Sends a preconfigured instance of a `NetworkRequest`, which expects a response of `ResponseType`.
    /// May throw in case the request was not successful.
    /// - Parameter requestConfiguration: The `NetworkRequestWithResponse` to be sent.
    func send<R>(request requestConfiguration: R) async throws -> R.ResponseType where R: NetworkRequestWithResponse {
        let urlRequest = try makeURLRequest(requestConfiguration: requestConfiguration)
        let httpResponse = try await getResponse(for: HTTPRequest(urlRequest: urlRequest), requestConfiguration: requestConfiguration)
        return try decodeResponse(request: requestConfiguration, httpResponse: httpResponse)
    }

    /// Sends a preconfigured instance of a `NetworkRequest`, which expects a response of `ResponseType`and
    /// contains a request body. May throw in case the request was not successful.
    /// - Parameter requestConfiguration: The `NetworkRequestWithResponse & NetworkRequestWithBody` to be sent.
    func send<R>(request requestConfiguration: R) async throws -> R.ResponseType where R: NetworkRequestWithResponse, R: NetworkRequestWithBody {
        var urlRequest = try makeURLRequest(requestConfiguration: requestConfiguration)
        urlRequest.httpBody = try body(request: requestConfiguration)
        let httpResponse = try await getResponse(for: HTTPRequest(urlRequest: urlRequest), requestConfiguration: requestConfiguration)
        return try decodeResponse(request: requestConfiguration, httpResponse: httpResponse)
    }
}

private extension NetworkManager {
    func makeURLRequest<R: NetworkRequest>(requestConfiguration: R) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: requestConfiguration.endpoint.absoluteString) else {
            throw Error.invalidURL(requestConfiguration.endpoint)
        }

        urlComponents.queryItems = try queryItems(request: requestConfiguration)

        guard let url = urlComponents.url else {
            throw Error.invalidURLComponents(urlComponents)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = requestConfiguration.headers.reduce(into: [String: String]()) { $0[$1.key.headerKey] = $1.value }

        return urlRequest
    }

    func getResponse<R: NetworkRequest>(for httpRequest: HTTPRequest, requestConfiguration: R) async throws -> HTTPResponse {
        var httpRequest = httpRequest
        intercept(request: requestConfiguration, httpRequest: &httpRequest)

        let rawResponse = try await urlSession.data(request: httpRequest.urlRequest)

        guard let httpUrlResponse = rawResponse.response as? HTTPURLResponse else {
            throw Error.responseIsNoHTTPURLResponse
        }

        var httpResponse = HTTPResponse(request: httpRequest, urlResponse: httpUrlResponse, data: rawResponse.data)
        try await intercept(request: requestConfiguration, httpResponse: &httpResponse)
        return httpResponse
    }
}
