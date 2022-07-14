import Foundation

/// A protocol providing a `baseURL` of type `URL`.
///
/// Note: `URL` itself is implementing the protocol itself, returning `self` as the `baseURL`.
public protocol BaseURLProvider {
    var baseURL: URL { get }
}
