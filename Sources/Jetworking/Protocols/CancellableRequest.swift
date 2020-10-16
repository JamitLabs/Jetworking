import Foundation

/// Protocol for requests that can be cancelled.
public protocol CancellableRequest {
    var identifier: Int { get }
    /// Cancels a request
    func cancel()
}

extension URLSessionTask: CancellableRequest {
    public var identifier: Int {
        return taskIdentifier
    }
}
