import Foundation

/// Base Protocol for `Interceptor`.
/// `Interceptors` are able to intercept a request and a response..
public protocol Interceptor {
    /**
     * # Summary
     * Intercepting the request to create the ability to modify the `URLRequest` before executing it. Example usages are adding request headers, authentication
     * and request logging.
     *
     * - Parameter request:
     *  The request to be intercepted.
     *
     * - Returns:
     * The intercepted and modified request.
     */
    func intercept(_ request: URLRequest) -> URLRequest

    /**
     * # Summary
     * Intercepting the response to add the ability to modify a response of a request. Additionally it is possible handle data and errors.
     *
     * - Parameter response:
     *  The response returned by the data task
     * - Parameter data:
     *  The data returned by the data task.
     * - Parameter error:
     *  The error returned by the data task.
     *
     * - Returns:
     * The intercepted and modified response.
     */
    func intercept(response: URLResponse?, data: Data?, error: Error?) -> URLResponse?
}

extension Interceptor {
    public func intercept(_ request: URLRequest) -> URLRequest {
        return request
    }

    public func intercept(response: URLResponse?, data: Data?, error: Error?) -> URLResponse? {
        return response
    }
}
