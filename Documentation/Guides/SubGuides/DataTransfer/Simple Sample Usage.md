# `DataTransfer`: Simple Sample Usage

In this guide, a very simple example of the `DataTransfer` submodule usage is presented. For more insights refer to the full documentation, the sample project and the tests.

---

When using the `DataTransfer` module on top of `Jetworking`, you can perform up- and download-tasks using a `Client` instance (which may be the same as the one used for endpoint calls):

```swift
let client: Client = .init(configuration: .init(baseURLProvider: URL(string: "https://random.org")!, interceptors: [])) // or use existing one

let url: URL = .init(string: "https://speed.hetzner.de/100MB.bin")!
client.download(url: url, progressHandler: nil) { (localURL, response, error) in
    if error == nil, let localURL = localURL {
        print("file saved to \(localURL)!")
    }
}
```

If you want to run uploads or downloads in the background, the client must have been configured before calling the corresponding method:

```swift
client.setupForDownloading(downloadExecutorType: .background)
```
