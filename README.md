<p align="center">
    <img src="https://raw.githubusercontent.com/JamitLabs/Jetworking/develop/Logo.png" width=500>
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
  • <a href="#documentation">Documentation</a>
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

To integrate `Jetworking` using the Xcode-built-in SPM, choose `File` → `Swift Packages` → `Add Package Dependency`. Enter the following url: `https://github.com/JamitLabs/Jetworking` and click `Next`. When asked about the version, leave the preselection and click `Next`. In the following step, select `Jetworking` and any further modules you may need and click `Finish`.

### Swift Package Manager (standalone)

To integrate using the standalone version of Apple's Swift Package Manager, add the following as a dependency to your `Package.swift` (replacing `<current-version>` with the current version, e. g. `0.9.0`):

```swift
.package(url: "https://github.com/JamitLabs/Jetworking.git", .upToNextMajor(from: "<current-version>"))
```

After specifying `"Jetworking"` and all further modules that you may need as a dependency of the target in which you want to use them, run `swift package update`.

## Documentation

The documentation of every `public` / `open` interface of `Jetworking` can be browsed at [https://jamitlabs.github.io/Jetworking](https://jamitlabs.github.io/Jetworking). Simple sample usage instructions are also given over there.

The documentation is split into different parts, covering the main module (`Jetworking`) as well as the different submodules:

| Name | Description | Documentation Coverage |
| ---  | ----------- | ------------- |
| `Jetworking` | The **base library**, defining fundamental types and protocols and providing basic HTTP networking functionality, in particular encompassing the common HTTP methods. | <img src="https://jamitlabs.github.io/Jetworking/badge.svg" alt="Documentation Coverage"> |
| `DataTransfer` | A module containing functionality concerning **uploading and downloading**. | <img src="https://jamitlabs.github.io/Jetworking/Modules/DataTransfer/badge.svg" alt="Documentation Coverage"> |

A very simple **iOS sample project** demonstrating basic use of Jetworking is available in the [Sample Project folder](/Sample Project).

## Contributing

We welcome everyone to work with us together, delivering helpful tooling to our open source community. Feel free to create an issue to ask questions, give feedback, report bugs or share your ideas for new features.

Before creating pull requests, please ensure that you have created a related issue ticket.

When creating a pull request with changes to the `public` / `open` interfaces and / or their documentation, make sure to update the documentation by running `make generate-docs` before. For further information, refer to the [Documentation Guide](/Documentation).

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](/LICENSE) file.
