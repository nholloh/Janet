# Declarative Endpoint Configuration

With Janet, each endpoint is declared with a `NetworkRequest` struct, that describes the properties of the endpoint and how to use it. Endpoints may have certain traits, e.g. they require query parameters or values need to be posted in the body of the HTTP request. Below you can find a table of supported traits. Use the protocols to specialise your `NetworkRequest`, which allows Janet to understand exactly how the request needs to be sent to your api.

| Trait                 | Description                                                         | Protocol                                                          |
|-----------------------|---------------------------------------------------------------------|-------------------------------------------------------------------|
| Has query parameters  | Used when your request needs to append query parameters to the URL. | `NetworkRequestWithQuery` [Link](Encodable_Query.md)              |
| Has request body      | Used when your request has a body.                                  | `NetworkRequestWithBody` [Link](Codable_Body.md#request-body)     |
| Expects response body | Used when you expect a decodable response.                          | `NetworkRequestWithResponse` [Link](Codable_Body.md#response-body)|

Here are some examples.

Service with response, which has no request body or request parameters:
```swift
    struct GetUsersRequest: NetworkRequestWithResponse {
        // The decodable response type we expect.
        typealias ResponseType = GetUsersResponse

        // The HTTP method used.
        let method: HTTPMethod = .get
        
        // The URL.
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!
    }
```

Service with query parameters and response:
```swift
    struct GetUsersRequestPaged: NetworkRequestWithQuery, NetworkRequestWithResponse {
        // The query type to be encoded into the URL.
        struct Query: Encodable {
            let page: Int
        }

        struct ResponseType: Decodable {
            let page: Int
            let total: Int
        }

        let method: HTTPMethod = .get
        
        // An instance of above query type
        let query: Encodable
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!
    }
```

Service with request body, without response:
```swift
    struct CreateUserRequest: NetworkRequestWithBody {
        
        // The body to be sent with the HTTP request.
        struct BodyType: Encodable {
            let name: String
            let job: String
        }

        let method: HTTPMethod = .post
        let body: BodyType
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!
    }
```
