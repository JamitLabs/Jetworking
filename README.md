<p align="center">
    <img src="https://raw.githubusercontent.com/JamitLabs/Jetworking/feature/readme/Logo.png" width=500>
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

`Jetworking` is a **multi-module** iOS and macOS library providing a **user-friendly interface for common networking tasks**.

## Installation

`Jetworking` can only be installed via the **Swift Package Manager**. 

Supported platforms are `iOS (10.0+)` and `macOS (10.12+)`.

### Swift Package Manager (Xcode-integrated)

To integrate SFSafeSymbols using the Xcode-built-in SPM, choose `File` → `Swift Packages` → `Add Package Dependency`. Enter the following url: `https://github.com/JamitLabs/Jetworking` and click `Next`. When asked about the version, leave the preselection and click `Next`. In the following step, select `Jetworking` and any further modules you may need and click `Finish`.

### Swift Package Manager (standalone)

To integrate using the standalone version of Apple's Swift Package Manager, add the following as a dependency to your `Package.swift` (replacing `<current-version>` with the current version, e. g. `0.9.0`):

```swift
.package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "<current-version>"))
```

After specifying `"Jetworking"` and all further modules that you may need as a dependency of the target in which you want to use them, run `swift package update`.

## Modules

Currently, Jetworking consists of the following modules:

| Name | Description | Documentation |
| ---  | ----------- | ------------- |
| `Jetworking` | The base library, defining fundamental types and protocols and providing basic HTTP networking functionality, in particular encompassing the common HTTP methods. | [Documentation](#usage) |
| `DataTransfer` | A module containing functionality concerning uploading and downloading. | [Documentation](Modules/DataTransfer/README.md) |

## Usage

In this section, the base module, `Jetworking`, is documented. For more insights, you might want to take a look at the `JetworkingTests`. Also, feel free to submit a PR with improvements to this documentation.

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

### Example project

An example project demonstrating the use of Jetworking is currently in development and will be provided soon.

## Contributing

We welcome everyone to work with us together delivering helpful tooling to our open source community. Feel free to create an issue to ask questions, give feedback, report bugs or share your new feature ideas. Before creating pull requests, please ensure that you have created a related issue ticket.

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](/LICENSE) file.
