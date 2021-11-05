# Jetworking

Jetworking is a multi-module library providing an implementation for common networking tasks.

Currently, Jetworking consists of the following modules:
  - `Jetworking`: The base library, defining fundamental types and protocols and providing basic HTTP networking functionality, in particular encompassing the common HTTP methods.
  - `DataTransfer`: A module containing functionality concerning uploading and downloading.

Jetworking's most important type is the `Client`. It allows you to access custom `Endpoint`s and perform GET, POST, PUT, PATCH and DELETE operations on them:
```swift
let client = Client(configuration: .init(baseURLProvider: URL(string: "https://random.org")!, interceptors: []))

let endpoint = Endpoint<Int>(pathComponent: "integers")
    .addQueryParameters(["num": "1", "min": "1", "max": "10", "col": "1", "base": "10", "format": "plain"])

// Perform GET request
client.get(endpoint: endpoint) { response, result in
    switch result {
    case .failure:
        print("error")

    case let .success(result):
        print("random number is \(result)")
    }
}
```

When using _DataTransfer_ on top of Jetworking, you can perform up- and download-tasks using the same `Client`:
```swift
let url = URL(string: "https://speed.hetzner.de/100MB.bin")!
client.download(url: url, progressHandler: nil) { (localURL, response, error) in
    if error == nil, let localURL = localURL {
        print("file saved to \(localURL)!")
    }
}
```

If you want up- or downloads to occur in the background, you must configure the client before calling `up-` or `download` the first time:
```swift
client.setupForDownloading(downloadExecutorType: .background)
```
