# 🤵🏽‍♀️ Janet

<p align=center style="font-size:5vw">— Just another networking kit —</p>

A thin HTTP networking layer built on URLSession for simple, declarative endpoint specification leveraging the power of async/await.

```swift
    // Defines what the service's endpoint looks like.
    struct GetUsersRequest: NetworkRequestWithResponse {
        // The decodable response type we expect.
        typealias ResponseType = GetUsersResponse

        // The HTTP method used.
        let method: HTTPMethod = .get
        
        // The URL.
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!
    }
    
    func getUsers(page: Int) throws async -> GetUsersResponse {
        // Create an instance of the request.
        let request = GetUsersRequest()
        
        // Create a network manager. You may use an shared instance.
        let networkManager = NetworkManager()
        
        // Send the request.
        return try await networkManager.send(request: request)
    }
```

## Features

The following features have been implemented or are planned for implementation.

- [x] [Declarative endpoint configuration](Documentation/Declarative_Endpoint_Config.md)
- [x] [Sending requests async/await with URLSession](Documentation/Sending_Requests.md)
- [x] [Encodable support for URL queries](Documentation/Encodable_Querym.md)
- [x] [Codable support for HTTP bodies](Documentation/Codable_Body.md)
- [x] [Custom value en-/decoding](Documentation/Custom_coders.md)
- [x] [HTTP response validation](Documentation/Response_Validation.md)
- [x] [Request/Response interception](Documentation/Interception.md)
- [ ] Unit and integration tests
- [ ] CI support
- [ ] Unit test and mock support
- [ ] DocC support
- [ ] SSL Pinning (TLS certificate and Public Key)
- [ ] Multipart & Multipart Form support
- [ ] File Up- and Download with Progress
- [ ] CocoaPods support
- [ ] Carthage support

If you would like to raise a feature request, please refer to the [contribution](#Contributing) section first.

## Installation

### Swift Package Manager

Please add the following line to the `dependencies` array in your Package.swift file:

```swift
    .package(url: "https://github.com/nholloh/Janet", from: "0.1.0")
```

## Supported Platforms

* iOS 13+
* macOS 10.15+
* watchOS 6+
* tvOS 13+

Prior to Xcode 13.2, concurrency features will only work for iOS 15, macOS 11, watchOS 8 and tvOS 15.
[Linux](https://github.com/nholloh/Network-iOS/issues/1) and [Windows](https://github.com/nholloh/Network-iOS/issues/2) are not supported. Please upvote the respective issue, if you'd like to see support.

## Usage

First, find out what the traits of the endpoint you want to connect to are. Then, use any combination of the protocols below to define your service configuration struct:

| Trait                 | Description                                                         | Protocol                     |
|-----------------------|---------------------------------------------------------------------|------------------------------|
| Has query parameters  | Used when your request needs to append query parameters to the URL. | `NetworkRequestWithQuery`    |
| Has request body      | Used when your request has a body.                                  | `NetworkRequestWithBody`     |
| Expects response body | Used when you expect a decodable response.                          | `NetworkRequestWithResponse` |

If none of the above applies, you may use the default `NetworkRequest` protocol.

Then, create your request configuration. Here are some examples:

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

Then, create an instance of your new request configuration and use it with an instance of `NetworkManager` to send your request:

```swift
    func getUsers(page: Int) throws async -> GetUsersResponse {
        // Create an instance of the request.
        let request = GetUsersRequest()
        
        // Create a network manager. You may use an shared instance.
        let networkManager = NetworkManager()
        
        // Send the request.
        return try await networkManager.send(request: request)
    }
```

For detailed documentation, please check the [Features](Documentation/Features.md).

## What does Janet stand for?

Its an acronym, which stands for:

**J** Just

**A** another

**NET** Network (library)

Also, its a reference to an incredibly helpful and empathetic AI from the series The Good Place. If you haven't seen it, you should definitely check it out!

## Contributing

For contributions, please consider the following scenarios:

### You find a bug

Please raise an issue and describe the bug you found. Feel free to fork and fix the bug, then raise a pull request with us. A collaborator of Janet will review it shortly and provide feedback.

### You have a feature request

In case you have a feature request, please raise an issue with the feature request. We will assess importance of features based on the number of upvotes of said issue. If you already have a concrete idea how this feature may work, you may of course fork and make the necessary changes. Please remember to update the documentation!

### IDE setup

There's no special setup required (as of now)! Just check out the code and start tinkering.