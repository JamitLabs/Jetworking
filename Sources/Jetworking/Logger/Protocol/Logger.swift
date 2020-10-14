import Foundation

/// Logger to be used within the logging interceptors.
/// To have your own logging mechanism simply conform to this protocol to be able to use your implementation within the interceptors.
public protocol Logger {
    /// Function which will be called from the logging interceptors within their intercept method.
    ///
    /// - parameter message: The message to be logged.
    func log(_ message: String)
}
