import Foundation

/// A type that represents a session cache interceptor used for intercepting a cached response.
public protocol SessionCacheInterceptor: Interceptor {
    /**
     * # Summary
     * Intercepting the cached response.
     *
     * - Parameter cachedResponse: The proposed cached response.
     *
     * - Returns: The intercepted cached response.
     */
    func intercept(cachedResponse: CachedURLResponse) -> CachedURLResponse
}
