#  Encodable URL query

```swift
public protocol NetworkRequestWithQuery: NetworkRequest {
    var query: Encodable { get }
}
```

To conform to the protocol, add a `query` property to your request type. You may supply this query dynamically (through the type's initialiser) or statically.

```swift
struct DynamicQueryNetworkRequest: NetworkRequest, NetworkRequestWithQuery {
    let method: HTTPMethod = .get
    let query: Encodable
    let endpoint: URL = .init(string: "https://mywebsite.net/api/sample")!
}

// or

struct StaticQueryNetworkRequest: NetworkRequest, NetworkRequestWithQuery {
    struct FilterQuery: Encodable {
        let filter: String
    }

    let method: HTTPMethod = .get
    let query = FilterQuery(filter: "customers-only")
    let endpoint: URL = .init(string: "https://mywebsite.net/api/sample")!
}
```

When [sending the request](Sending_Requests.md), the `NetworkManager` will convert your encodable query into key value pairs, which are then added to the URLRequest. The static request above will produce the following URL: `https://mywebsite.net/api/sample?filter=customers-only`.
