import Foundation

/// Implementation of a session cache interceptor which allows the response data from an `HTTP/HTTPS` request to be temporarily stored.
public final class DefaultSessionCacheIntercepter: SessionCacheInterceptor {
    public static let expectedSchemes: [String] = ["http", "https"]

    private(set) var storagePolicy: URLCache.StoragePolicy
    private var schemes: [String]

    public init(storagePolicy: URLCache.StoragePolicy = .allowedInMemoryOnly, for schemes: [String] = expectedSchemes) {
        self.storagePolicy = storagePolicy
        self.schemes = schemes
    }

    public func intercept(cachedResponse: CachedURLResponse) -> CachedURLResponse {
        let responseScheme = cachedResponse.response.url?.scheme
        guard schemes.contains(responseScheme ?? "") else { return cachedResponse }

        return .init(
            response: cachedResponse.response,
            data: cachedResponse.data,
            userInfo: cachedResponse.userInfo,
            storagePolicy: storagePolicy
        )
    }
}
