import Foundation

/// The protocol request interceptors need to conform to to be able to be used to intercept the request.
public protocol RequestInterceptor {
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
}
