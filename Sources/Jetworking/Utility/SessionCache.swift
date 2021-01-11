import Foundation

@dynamicMemberLookup
public final class SessionCache {
    private let cache: URLCache
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let interceptors: [SessionCacheInterceptor]

    // MARK: - Initializers
    /// Creates a `SessionCache` instance with a configuration used within the `Client` instance.
    ///
    /// - Parameters:
    ///   - configuration: A client configuration.
    convenience init(configuration: Configuration) {
        self.init(
            cache: configuration.cache,
            encoder: configuration.encoder,
            decoder: configuration.decoder,
            interceptors: configuration.interceptors.compactMap {
                $0 as? SessionCacheInterceptor
            }
        )
    }

    /// Creates a `SessionCache` instance in a comprehensive way.
    ///
    /// - Parameters:
    ///   - cache: A `URLCache` instance.
    ///   - encoder: An encoder for `json` format.
    ///   - decoder: A decoder for `json` format.
    ///   - interceptors: A collection of `SessionCacheInterceptor` instances.
    init(cache: URLCache, encoder: JSONEncoder, decoder: JSONDecoder, interceptors: [SessionCacheInterceptor]) {
        self.cache = cache
        self.encoder = encoder
        self.decoder = decoder
        self.interceptors = interceptors
    }

    subscript<T>(dynamicMember keyPath: KeyPath<URLCache, T>) -> T {
        cache[keyPath: keyPath]
    }

    // MARK: - Retrieval
    /// Queries an object with specified type for the given request.
    ///
    /// - Parameter dataType: The data type of the cached data.
    /// - Parameter request: The URL request whose cached URL response is desired.
    ///
    /// Returns: (Optional) A cached object.
    public func query<T: Codable>(_ dataType: T.Type, for request: URLRequest) -> T? {
        guard let data = cache.cachedResponse(for: request)?.data else { return nil }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            cache.removeCachedResponse(for: request) // Remove on failure
            return nil
        }
    }

    /// Queries a `URL` of existing resource item loaded from the given request.
    ///
    /// - Parameter request: The URL request whose cached URL response is desired.
    ///
    /// Returns: (Optional) A URL of resource item.
    public func queryResourceItemURL(for request: URLRequest) -> URL? {
        guard let url = query(URL.self, for: request) else { return nil }

        guard url.isFileURL, (try? url.checkResourceIsReachable()) != true else { return url }

        // Remove cached object if resource item is invalid.
        cache.removeCachedResponse(for: request)

        return nil
    }

    /// Queries a `CachedURLResponse` object for the given request.
    ///
    /// - Parameter request: The URL request whose cached URL response is desired.
    ///
    /// Returns: (Optional) A cached URL response
    public func queryCachedResponse(for request: URLRequest) -> CachedURLResponse? {
        cache.cachedResponse(for: request)
    }

    // MARK: - Store
    /// Stores an object for a specified request included in the given task.
    ///
    /// - Parameter object: An object to be cached.
    /// - Parameter task: The session task whose response is to be cached.
    public func store<T: Codable>(_ object: T, from task: URLSessionTask) {
        guard
            let request = task.originalRequest ?? task.currentRequest,
            let response = task.response
        else { return }

        store(object, from: response, for: request)
    }

    /// Stores an object from a response for a specified request.
    ///
    /// - Parameter object: An object to be cached.
    /// - Parameter response: A response to a URL request.
    /// - Parameter request: The request for which the cached URL response is being stored.
    public func store<T: Codable>(_ object: T, from response: URLResponse, for request: URLRequest) {
        guard let data = try? encoder.encode(object) else { return }

        var cachedResponse = CachedURLResponse(response: response, data: data, storagePolicy: .notAllowed)
        cachedResponse = interceptors.reduce(cachedResponse) { cachedResponse, interceptor in
            return interceptor.intercept(cachedResponse: cachedResponse)
        }

        cache.storeCachedResponse(cachedResponse, for: request)
    }

    // MARK: - Removal
    /// Removes cached object corresponding a specified request if any.
    public func removeObject(for request: URLRequest) {
        cache.removeCachedResponse(for: request)
    }

    /// Removes all cached responses from current storage.
    public func reset() {
        cache.removeAllCachedResponses()
    }
}
