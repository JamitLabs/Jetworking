import Foundation

/// The request executor currently supported.
/// - `sync` for a synchronous execution of requests.
/// - `async` for an asynchronous execution of requests.
/// - `custom` for a custom execution of requests provided by the caller.
public enum RequestExecutorType {
    case async
    case sync
    case custom(RequestExecutor.Type)
}
