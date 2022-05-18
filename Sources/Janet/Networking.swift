//
//  Networking.swift
//  
//
//  Created by Niklas Holloh on 25.04.22.
//

import Foundation

/// A protocol around the `NetworkManager` to be used for dependency injection.
public protocol Networking {
    // MARK: - Public Configuration
    /// Gets or sets the default encoder for HTTP bodies. Default is `JSONEncoder`.
    var httpBodyEncoder: DataEncoding { get set }

    /// Gets or sets the default decoder for HTTP bodies. Default is `JSONDecoder`.
    var httpBodyDecoder: DataDecoding { get set }

    /// Gets or sets the default request interceptor, which is used to inspect or mutate a request
    /// after its construction (URLRequest), right before it is passed to `URLSession` for sending it
    /// to a web host. Default is empty.
    var requestInterceptor: NetworkRequestInterceptor { get set }

    /// Gets or sets the default response interceptor, which is used to inspect or mutate a response
    /// after receiving it from `URLSession`, before its data may be decoded and passed back to
    /// the call site. Default is`ValidateHTTPStatusResponseInterceptor.default`.
    var responseInterceptor: NetworkResponseInterceptor { get set }

    // MARK: - Send
    /// Sends a preconfigured instance of a `NetworkRequest`, which does not expect a response.
    /// May throw in case the request was not successful.
    /// - Parameter requestConfiguration: The `NetworkRequest` to be sent.
    func send<R: NetworkRequest>(request requestConfiguration: R) async throws

    /// Sends a preconfigured instance of a `NetworkRequest`, which does not expect a response and
    /// contains a request body. May throw in case the request was not successful.
    /// - Parameter requestConfiguration: The `NetworkRequestWithBody` to be sent.
    func send<R: NetworkRequestWithBody>(request requestConfiguration: R) async throws

    /// Sends a preconfigured instance of a `NetworkRequest`, which expects a response of `ResponseType`.
    /// May throw in case the request was not successful.
    /// - Parameter requestConfiguration: The `NetworkRequestWithResponse` to be sent.
    func send<R>(request requestConfiguration: R) async throws -> R.ResponseType where R: NetworkRequestWithResponse

    /// Sends a preconfigured instance of a `NetworkRequest`, which expects a response of `ResponseType`and
    /// contains a request body. May throw in case the request was not successful.
    /// - Parameter requestConfiguration: The `NetworkRequestWithResponse & NetworkRequestWithBody` to be sent.
    func send<R>(request requestConfiguration: R) async throws -> R.ResponseType where R: NetworkRequestWithResponse, R: NetworkRequestWithBody
}
