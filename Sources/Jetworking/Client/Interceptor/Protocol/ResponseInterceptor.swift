import Foundation

/// The protocol response interceptors need to conform to to be able to be used to intercept the response.
public protocol ResponseInterceptor: Interceptor {
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
