import Foundation

/// The configuration used within the client.
public struct Configuration {
    let baseURL: URL
    let requestInterceptors: [RequestInterceptor]
    let responseInterceptors: [ResponseInterceptor]
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let requestExecutorType: RequestExecutorType

    /**
     * Initialises a new configuration instance to use within the client.
     *
     * - Parameter baseURL: The base URL used within the client.
     * - Parameter requestInterceptors: A list of request interceptors to intercept the request before sending it.
     * - Parameter responseInterceptors: A list of response interceptors to intercept the response before returning it.
     * - Parameter encoder: The encoder to use to encode the request body data before sending it.
     * - Parameter decoder: The decoder to use to decode the response body data before returning it.
     * - Parameter requestExecutorType: The request executor type to use to execute the requests.
     */
    init(
        baseURL: URL,
        requestInterceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor],
        encoder: JSONEncoder,
        decoder: JSONDecoder,
        requestExecutorType: RequestExecutorType = .async
    ) {
        self.baseURL = baseURL
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
        self.encoder = encoder
        self.decoder = decoder
        self.requestExecutorType = requestExecutorType
    }
}
