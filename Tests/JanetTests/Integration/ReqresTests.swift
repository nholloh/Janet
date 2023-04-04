//
//  ReqresTests.swift
//  
//
//  Created by Holloh, Niklas on 04.04.23.
//

import Foundation
import XCTest
import Janet

protocol ReqresNetworkRequest: NetworkRequest {
    var path: String { get }
}

extension ReqresNetworkRequest {
    var endpoint: URL {
        URL(string: "https://reqres.in/api/")!.appendingPathComponent(path)
    }
}

class ReqresTests: XCTestCase {
    private lazy var networkManager: NetworkManager! = {
        let n = NetworkManager()
        n.requestInterceptor = LogRequestInterceptor(log: { print($0) })
        n.responseInterceptor = LogResponseInterceptor(log: { print($0) })
            .chain(before: ValidateHTTPStatusResponseInterceptor.default)
        return n
    }()
    
    override func tearDown() {
        super.tearDown()
        networkManager = nil
    }
}

// MARK: - GET Request With Query And Response
// Tests: NetworkRequestWithQuery, NetworkRequestWithResponse, Query Encoding, Decoding
extension ReqresTests {
    struct GetUsersRequest: ReqresNetworkRequest, NetworkRequestWithQuery, NetworkRequestWithResponse {
        struct QueryType: Encodable {
            let page: Int
        }

        struct ResponseType: Decodable {
            let page: Int
            let total: Int
        }

        let method: HTTPMethod = .get
        let query: Encodable
        let path = "users"
    }
    
    func test_GetRequestWithQuery() async throws {
        // given
        let request = GetUsersRequest(query: GetUsersRequest.QueryType(page: 2))
        
        // when
        let result = try await networkManager.send(request: request)
        
        // then
        XCTAssertEqual(result.page, 2)
    }
}

// MARK: - POST Request With Body And Response
// Test: NetworkRequestWithBody, NetworkRequestWithResponse, Body Encoding, Decoding, Custom Response Interceptor
extension ReqresTests {
    struct PostUserRequest: ReqresNetworkRequest, NetworkRequestWithBody, NetworkRequestWithResponse, NetworkRequestWithResponseInterceptor {
        struct BodyType: Encodable {
            let name: String
            let job: String
        }

        struct ResponseType: Decodable {
            let id: String
        }

        let method: HTTPMethod = .post
        let body: BodyType
        let path = "users"
        
        let responseInterceptor: NetworkResponseInterceptor = ValidateHTTPStatusResponseInterceptor(allowedStatusCodes: 201..<202)
    }
    
    func test_PostRequestWithBody() async throws {
        // given
        let request = PostUserRequest(body: .init(name: "Hans", job: "Zimmermann"))
        
        // when / then
        _ = try await networkManager.send(request: request)
    }
}

// MARK: - POST Request With Invalid Body And Response
// Test: NetworkRequestWithBody, NetworkRequestWithResponse, Body Encoding, Decoding, Custom Response Interceptor
extension ReqresTests {
    struct PostRegisterRequestInvalid: ReqresNetworkRequest, NetworkRequestWithBody, NetworkRequestWithResponse, NetworkRequestWithResponseInterceptor {
        struct BodyType: Encodable { }

        struct ResponseType: Decodable {
            let token: String
            let id: String
        }

        let method: HTTPMethod = .post
        let body: BodyType
        let path = "register"
        
        let responseInterceptor: NetworkResponseInterceptor = ValidateHTTPStatusResponseInterceptor(allowedStatusCodes: 200..<201)
    }
    
    func test_PostRequestWithInvalidBody() async throws {
        // given
        let request = PostRegisterRequestInvalid(body: .init())
        
        // when / then
        let error = await XCTAssertThrowsError(try await networkManager.send(request: request))
        guard let error else { return }
        guard let networkManagerError = error as? NetworkManager.Error else {
            XCTFail("Error has incorrect type \(error)")
            return
        }
        
        guard case .errorStatusCode(_, _) = networkManagerError else {
            XCTFail("Error has incorrect case \(networkManagerError)")
            return
        }
    }
}
