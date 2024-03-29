# `DataTransfer`

When using the `DataTransfer` module on top of `Jetworking`, you can perform up- and download-tasks using a `Client` instance (which may be the same as the one used for endpoint calls):

```swift
let client = Client(configuration: .init(baseURLProvider: URL(string: "https://random.org")!, interceptors: [])) // or use existing one

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

For a full overview over all options offered by the `DataTransfer` module, you may take a look at the `DataTransferTests`.

Also, feel free to submit a PR with improvements to this documentation.
