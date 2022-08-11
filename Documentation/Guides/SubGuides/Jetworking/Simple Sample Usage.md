# `Jetworking`: Simple Sample Usage

In this guide, very simple sample usage of the main module, `Jetworking`, is presented. For more insights, refer to the full documentation, the example project and / or the tests.

---

```swift
// `Client` is Jetworking's most important type
let client = Client(configuration: .init(baseURLProvider: URL(string: "https://random.org")!, interceptors: []))

let endpoint = Endpoint<Int>(pathComponent: "integers")
    .addQueryParameters(["num": "1", "min": "1", "max": "10", "col": "1", "base": "10", "format": "plain"])

// With a `Client` instance, custom endpoints can be accessed with typical HTTP methods
// Here, a GET request is performed on the previously defined endpoint
client.get(endpoint: endpoint) { response, result in
    switch result {
    case .failure:
        print("error")

    case let .success(result):
        print("random number is \(result)")
    }
}
```
