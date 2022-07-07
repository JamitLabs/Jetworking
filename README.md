<p align="center">
    <img src="https://raw.githubusercontent.com/JamitLabs/Jetworking/feature/readme/Logo.png" width=600>
</p>

<p align="center">
    <a href="https://app.bitrise.io/app/6d6f72dca6056dce#/builds">
        <img src="https://app.bitrise.io/app/6d6f72dca6056dce.svg?token=fzLBK2JeJ4CWdSUxC7C9Fg&branch=develop" alt="Build Status">
    </a>
    <a href="#">
        <img src="https://img.shields.io/badge/swift-5.3-FFAC45.svg" alt="Swift: 5.3">
    </a>
    <a href="https://github.com/JamitLabs/Jetworking/releases">
    <img src="https://img.shields.io/badge/version-0.9.0-blue.svg"
    alt="Version: 0.9.0">
    </a>
    <a href="#">
    <img src="https://img.shields.io/badge/Platforms-iOS%20|%20macOS-FF69B4.svg"
        alt="Platforms: iOS – macOS">
    </a>
    <a href="https://github.com/JamitLabs/Jetworking/blob/develop/LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" alt="License: MIT">
    </a>
    <a href="https://github.com/apple/swift-package-manager">
        <img src="https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg" alt="SwiftPM: Compatible">
    </a>
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#modules">Modules</a>
  • <a href="#contributing">Contributing</a>
  • <a href="#license">License</a>
  • <a href="https://github.com/JamitLabs/Jetworking/issues">Issues</a>
  • <a href="https://github.com/JamitLabs/Jetworking/pulls">Pull Requests</a>
</p>

Jetworking is a multi-module library providing an implementation for common networking tasks.

## Installation

TODO

## Usage

TODO

An example project demonstrating the use of Jetworking is currently in development and will be provided soon.

## Modules

Currently, Jetworking consists of the following modules:
  - `Jetworking`: The base library, defining fundamental types and protocols and providing basic HTTP networking functionality, in particular encompassing the common HTTP methods.
  - `DataTransfer`: A module containing functionality concerning uploading and downloading.
  
TODO: Move Module Documentation to respective README

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

## Contributing

We welcome everyone to work with us together delivering helpful tooling to our open source community. Feel free to create an issue to ask questions, give feedback, report bugs or share your new feature ideas. Before creating pull requests, please ensure that you have created a related issue ticket.

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](/LICENSE) file.
