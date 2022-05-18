#  Interception

Janet allows you to intercept requests right before they leave the device, or responses right after they come in from the server. This can be particularly useful, for example if want to supply an additional header for every request sent to the backend. Janet itself uses this concept to validate HTTP status codes of incoming server responses.

## Network request interception

Network request interception happens immediately before the URLRequest object is passed to URLSession to be taken care of and sent by the system. See below, how a `NetworkRequestInterceptor` is defined:

```swift
/// A request interceptor, which will be executed before the request is sent to the backend.
public protocol NetworkRequestInterceptor {
    /// Intercepts a request as sent to the backend. Data may be mutated on the original request.
    /// - Parameter request: The request, on which mutation is possible.
    func intercept(request: inout HTTPRequest)
}
```

A request interceptor receives a mutable copy of an HTTPRequest, which is a Janet-specific type that wraps around a URLRequest to provide more context, if needed. The URLRequest inside the HTTPRequest already contains all fields that have previously been configured in your `NetworkRequest`:

* Endpoint (incl. query)
* HTTP method
* Headers
* Body

That is, a request interceptor is able to read and modify all of these properties before sending the request to the backend. A common use case is to provide a session token as an additional header for all requests. Using an interceptor, you don't need to define this header on each single NetworkRequest, but can globally add it in the NetworkManager.

### Creating your own request interceptor

Create a class that conforms to `NetworkRequestInterceptor`. By convention, a request interceptor should carry the term `Request` somewhere in its name. I reccommend using a reference type, since an interceptor should not carry state, and can therefore be a shared instance reused for every request across the app. This helps reduce memory footprint and compute time for allocation on the stack. 

```swift
class RequestIDInterceptor: NetworkRequestInterceptor {
    static let `default` = RequestIDInterceptor()

    func intercept(request: inout HTTPRequest) {
        // Every Janet request comes with a UUID, which is just not part of the header.
        // Let's change that!
        
        request.urlRequest.addValue(request.uuid.uuidString, forHTTPHeaderField: "X-REQUEST-ID")
    }
}
```

For simple request interceptors, you may use the `ClosureRequestInterceptor`. The code below is equivalent to the explicitly defined class above.

```swift
let interceptor = ClosureRequestInterceptor { request in 
    request.urlRequest.addValue(request.uuid.uuidString, forHTTPHeaderField: "X-REQUEST-ID")
}
```

### Using your request interceptor

To use your interceptor, you need to set it in the `NetworkManager`'s `requestInterceptor` property.

Declaration:
```swift
    /// Gets or sets the default request interceptor, which is used to inspect or mutate a request
    /// after its construction (URLRequest), right before it is passed to `URLSession` for sending it
    /// to a web host. Default is empty.
    var requestInterceptor: NetworkRequestInterceptor { get set }
```

Usage:
```swift
networkManager.requestInterceptor = RequestIDInterceptor.default
```

This will execute the interceptor for every request, which is sent through this `NetworkManager` instance. For interceptors that should only be executed on specific requests, read the chapter on [Interceptor scope](#interceptor-scope). 

The interface above only allows for one interceptor. If you need multiple interceptors to be executed, read the chapter on [Chaining interceptors](#chaining-interceptors).

## Network response interception

Similar to network requests, network responses can be intercepted. Interception happens after the response has been received, before returning to the call site. In contrast to request interceptors, response interceptors are executed in an async context and can throw. This allows them to throw errors, or even recover from errors with asynchronous operations. For example, you may create an interceptor, which requests a new session with the backend when receiving status 401 and then retries the original request, before returning.

Please see below, how a response interceptor is defined:

```swift
/// A response interceptor, which will be executed after the backend's response has been received.
public protocol NetworkResponseInterceptor {
    /// Intercepts a response as received by the backend. Data may be mutated on the original response.
    /// - Parameter response: The response, on which mutation is possible.
    func intercept(response: inout HTTPResponse) async throws
}
```

A response interceptor receives a mutable copy of an HTTPResponse object, which in turn carries the original `HTTPRequest`, the `HTTPURLResponse` and any data received from the backend. The interceptor may inspect and modify this data or initiate other async operations.

### Creating your own response interceptor

Similar to the request interceptor [above](#creating-your-own-request-interceptor), create a class that conforms to `NetworkResponseInterceptor`:

```swift
class BackendBusinessErrorResponseInterceptor: NetworkResponseInterceptor {
    static let `default` = BackendBusinessErrorResponseInterceptor()

    enum Error: Swift.Error {
        case backendBusinessError
    }

    func intercept(response: inout HTTPResponse) async throws {
        if response.urlResponse.value(forHTTPHeaderField: "X-BUSINESS-ERROR") == "true" {
            throw Error.backendBusinessError
        }
    }
}
```

The pendant to `ClosureRequestInterceptor` exists for responses, too:

```swift
enum Error: Swift.Error {
    case backendBusinessError
}

let interceptor = ClosureResponseInterceptor { response in 
    if response.urlResponse.value(forHTTPHeaderField: "X-BUSINESS-ERROR") == "true" {
        throw Error.backendBusinessError
    }
}
```

### Using your response interceptor

To use your interceptor, you need to set it in the `NetworkManager`'s `responseInterceptor` property.

Declaration:
```swift
    /// Gets or sets the default response interceptor, which is used to inspect or mutate a response
    /// after receiving it from `URLSession`, before its data may be decoded and passed back to
    /// the call site. Default is`ValidateHTTPStatusResponseInterceptor.default`.
    var responseInterceptor: NetworkResponseInterceptor { get set }
```

Usage:
```swift
networkManager.responseInterceptor = BackendBusinessErrorResponseInterceptor.default
```

This will execute the interceptor for every response, which is incoming for this `NetworkManager` instance. For interceptors that should only be executed on specific requests, read the chapter on [Interceptor scope](#interceptor-scope). 

The interface above only allows for one interceptor. If you need multiple interceptors to be executed, read the chapter on [Chaining interceptors](#chaining-interceptors).

## Interceptor Scope

Interceptors can be set on global and request scope.

### Global scope

Global interceptors are set on the `NetworkManager` as outlined above. They are executed for every request and response running through the particular `NetworkManager` instance. Use the `requestInterceptor` and `responseInterceptor` properties.

For examples, please refer to the sections above.

### Request scope

Interceptors can be set on request scope, when the `NetworkRequest` is specialised with the appropriate protocol:

**For request interceptors:** `NetworkRequestWithRequestInterceptor`
**For response interceptors:** `NetworkRequestWithResponseInterceptor` 

They add a `requestInterceptor` or `responseInterceptor` property to your `NetworkRequest`, that you can assign your interceptor to. Based on the protocol, Janet will recognise use of request scope interceptors and include them in the interceptor chain.

### Scope execution order

For request interceptors, execution order is as follows:

1. Request Scope Interceptor(s)
2. Global Scope Interceptor(s)

For response interceptors, execution order is inverted:

1. Global Scope Interceptor(s)
2. Request Scope Interceptor(s)

This is to allow for logging of the exact request sent to the backend, and response received by the backend with a Global Scope Interceptor. In order to facilitate this, the logging interceptor needs to be the last thing executed before we send the request, and the first interceptor before we further process (and potentially mutate) the response.

## Chaining interceptors

According to the interface of `NetworkRequestWith____Interceptor` and `NetworkManager` only a single interceptor of each kind is allowed. However, you can chain interceptors into higher-order interceptors, which execute its child interceptors one after another. To do so, you can use any of the below methods:

```swift
let firstRequestIDThenLogInterceptor = requestIDInterceptor.chain(before: logRequestInterceptor)
let firstLogThenBackendErrorResponseInterceptor = backendErrorResponseInterceptor.chain(after: logResponseInterceptor)

let requestInterceptorList = [
    fooRequestInterceptor,
    barRequestInterceptor,
    logRequestInterceptor
]

let combinedInterceptor = ChainedRequestInterceptor.chain(inOrder: requestInterceptorList)
```

Every resulting higher-order interceptor also conforms to its respective interceptor protocol, allowing you to chain infinitely. The resulting memory structure will look like a binary tree with a predefined order of execution for each item. If possible, create these higher-order interceptors once during app start (preferably in background) and keep them in memory for the app's lifetime.
