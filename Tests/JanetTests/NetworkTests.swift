import XCTest
@testable import Janet

final class NetworkTests: XCTestCase {

    struct SampleRequestWithQuery: NetworkRequest, NetworkRequestWithQuery, NetworkRequestWithResponse, NetworkRequestWithRequestInterceptor {
        struct QueryType: Encodable {
            let page: Int
        }

        struct ResponseType: Decodable {
            let page: Int
            let total: Int
        }

        let method: HTTPMethod = .get
        let query: Encodable
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!

        let requestInterceptor: NetworkRequestInterceptor = ClosureRequestInterceptor {
            print($0)
        }
    }

    func test_SampleRequestWithQuery() async throws {
        let request = SampleRequestWithQuery(query: SampleRequestWithQuery.QueryType(page: 2))
        let manager = NetworkManager()
        let result = try await manager.send(request: request)
    }
}
