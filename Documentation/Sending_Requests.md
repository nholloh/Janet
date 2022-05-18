#  Sending requests

To send a request, you need a custom type implementing `NetworkRequest`. If you don't have one already, be sure to check the [Declarative Endpoint Configuration](Declarative_Endpoint_Config.md).

Suppose your request looks like this:

```swift
    struct CreateUserRequest: NetworkRequestWithBody {
        let method: HTTPMethod = .post
        let body: CreateUserModel
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!
    }
```

In your service or data source class, make sure to have an instance of `NetworkManager` at your disposal. Alternatively, you may use `Networking`, which mirrors the `NetworkManager`s interface and facilitates dependency injection.

```swift
class UserDataSource {
    private let networkManager: Networking // use NetworkManager as type alternatively
    
    init(networkManager: Networking) {
        self.networkManager = networkManager
    }
    
    // MARK: - CreateUserRequest
    struct CreateUserRequest: NetworkRequestWithBody {
        let method: HTTPMethod = .post
        let body: CreateUserModel
        let endpoint: URL = .init(string: "https://reqres.in/api/users")!
    }
    
    func createUser(_ user: CreateUserModel) async throws {
        try await networkManager.send(request: CreateUserRequest(body: user))
    }
}
```

Then, invoke `networkManager.send(request: _)`. If your request is `NetworkRequestWithResponse`, the signature of the send method will change to one that returns the specified `ResponseType`.
