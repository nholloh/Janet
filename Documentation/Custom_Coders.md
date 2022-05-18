#  Custom en-/decoding

In case your api does not use JSON, you may use or create your own en- and decoders. Let's assume your backend uses XML for the following cases.

## Custom encoder

Your custom encoder will have to conform to `DataEncoding`, to use it with Janet:

```swift
public class XMLEncoder: DataEncoding { 

    func encode<T: Encodable>(_ model: T) throws -> Data {
        // ...
    }

}
```

## Custom decoder

In similar fashion to the encoder, a custom decoder needs to conform to `DataDecoding`:

```swift
public class XMLDecoder: DataDecoding { 

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        // ...
    }

}
```

## Configuring custom coders

In line with using customized json coders, you can plug your custom coder into Janet globally or at request level:

### Global coder customization

After creating the `NetworkManager` instance, you can customize the default coders by setting the `httpBodyEncoder` and `httpBodyDecoder` properties.

```swift
    networkManager.httpBodyEncoder = XMLEncoder()
    networkManager.httpBodyDecoder = XMLDecoder()
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
        
        // Create your custom XMLDecoder here.
        let httpBodyDecoder: DataDecoding = XMLDecoder()
    }
```

## JSON support

Support for JSON comes out of the box with Janet. Maybe you saw the resemblence of `encode` and `decode` with the `JSONEncoder` and `JSONDecoder` interface already. Janet extends these types for conformance with `DataEncoding` and `DataDecoding`. You may create and customize your own instances and plug them into any property that requires a respective coder. Read up on how to use customized json coders [here](Codable_Body.md#changing-default-coders).
