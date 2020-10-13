import Foundation

/// Protocol for requests that can be cancelled.
public protocol CancellableRequest {
    /// Cancels a request
    func cancel()
}

extension URLSessionTask: CancellableRequest {}
