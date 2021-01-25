import Foundation

/// Base Protocol for `Interceptor`.
/// `Interceptors` are able to intercept a request or a response.
public protocol Interceptor {
    /**
     * # Summary
     * Intercepting the request.
     *
     * - Parameter request:
     *  The request to be intercepted.
     *
     * - Returns:
     * The intercepted request.
     */
    func intercept(_ request: URLRequest) -> URLRequest

    /**
     * # Summary
     * Intercepting the response.
     *
     * - Parameter data:
     *  The data returned by the data task.
     * - Parameter response:
     *  The response returned by the data task
     * - Parameter error:
     *  The error returned by the data task.
     *
     * - Returns:
     * The intercepted response.
     */
    func intercept(data: Data?, response: URLResponse?, error: Error?) -> URLResponse?
}

extension Interceptor {
    public func intercept(_ request: URLRequest) -> URLRequest {
        return request
    }

    public func intercept(data: Data?, response: URLResponse?, error: Error?) -> URLResponse? {
        return response
    }
}
