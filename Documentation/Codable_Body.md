#  Codable support for HTTP bodies

## Request body

If you need to append a body to your HTTP request (e.g. making a POST request to create a new resource), specialize your `NetworkRequest` with the `NetworkRequestWithBody` protocol.

```swift
public protocol NetworkRequestWithBody: NetworkRequest {
    associatedtype BodyType: Encodable

    var body: BodyType { get }
    var httpBodyEncoder: DataEncoding? { get }
}
```

To conform to the protocol, add a `BodyType` struct and a `body` property to your request type. You may supply this body dynamically (through the type's initialiser) or statically.

```swift
struct DynamicQueryNetworkRequest: NetworkRequest, NetworkRequestWithBody {
    struct BodyType: Encodable {
        let name: String
    }
    
    let method: HTTPMethod = .get
    let body: BodyType
    let endpoint: URL = .init(string: "https://mywebsite.net/api/sample")!
}

// or

struct StaticQueryNetworkRequest: NetworkRequest, NetworkRequestWithBody {
    let method: HTTPMethod = .get
    let body = CreateUserModel(name: "Janet")
    let endpoint: URL = .init(string: "https://mywebsite.net/api/sample")!
}
```

When [sending the request](Sending_Requests.md), the `NetworkManager` will convert your encodable body through a `DataEncoding` type. By default, Swift's `JSONEncoder` will be used with default settings. To customize this, view [Changing default coders](#changing-default-coders)

## Response body

If you plan to receive data from your api, you can specialize your request with the `NetworkRequestWithResponse` protocol.

```swift
public protocol NetworkRequestWithResponse: NetworkRequest {
    associatedtype ResponseType: Decodable

    var httpBodyDecoder: DataDecoding? { get }
}
```

To conform to the protocol, add a `ResponseType` struct to your request type. Make sure that this type conforms to `Decodable`.

```swift
    struct CreateUserRequest: NetworkRequestWithResponse {
        
        // The body expected in the server's response.
        typealias ResponseType = [User]
        
        struct User: Decodable {
            let name: String
            let job: String
        }

        let method: HTTPMethod = .post
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!
    }
```

You should notice that the signature of the `networkManager.send(request: _)` method has changed. It will now return a result, which is the response type declared in your request struct.

## Changing default coders

If you plan to customize value en- and decoding, you can create a custom instance of `JSONEncoder` or `JSONDecoder`. If you need support for other formats than JSON, check the documentation for [Custom Coders](Custom_Coders.md). Sticking to JSON, you have two options:

### Global coder customization

After creating the `NetworkManager` instance, you can customize the default coders by setting the `httpBodyEncoder` and `httpBodyDecoder` properties.

```swift
    let myJsonEncoder = JSONEncoder()
    myJsonEncoder.keyEncodingStrategy = .convertToSnakeCase
    
    let myJsonDecoder = JSONDecoder()
    myJsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    
    networkManager.httpBodyEncoder = myJsonEncoder
    networkManager.httpBodyDecoder = myJsonDecoder
```

### Request-specific coder customization

The protocols `NetworkRequestWithBody` and `NetworkRequestWithResponse` have `httpBodyEncoder` and `httpBodyDecoder` properties, just like the `NetworkManager`. When specifying a en- or decoder here, this coder will take precedence over the default coder in the `NetworkManager`. Default for this property is `nil` which makes `NetworkManager` fall back to the global configuration.

```swift
    struct CreateUserRequest: NetworkRequestWithResponse {
        typealias ResponseType = [User]
        
        struct User: Decodable {
            let name: String
            let job: String
        }

        let method: HTTPMethod = .post
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!
        
        // Create your custom JSONDecoder here.
        let httpBodyDecoder: DataDecoding = {
            let myJsonDecoder = JSONDecoder()
            myJsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            return myJsonDecoder
        }()
    }
```
