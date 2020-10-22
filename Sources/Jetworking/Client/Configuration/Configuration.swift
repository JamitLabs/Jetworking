import Foundation

/// The configuration used within the client.
public struct Configuration {
    let baseURL: URL
    let requestInterceptors: [RequestInterceptor]
    let responseInterceptors: [ResponseInterceptor]
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let requestExecutorType: RequestExecutorType
    let downloadExecutorType: DownloadExecutorType
    let uploadExecutorType: UploadExecutorType

    /**
     * Initialises a new configuration instance to use within the client.
     *
     * - Parameter baseURL: The base URL used within the client.
     * - Parameter requestInterceptors: A list of request interceptors to intercept the request before sending it.
     * - Parameter responseInterceptors: A list of response interceptors to intercept the response before returning it.
     * - Parameter encoder: The encoder to use to encode the request body data before sending it.
     * - Parameter decoder: The decoder to use to decode the response body data before returning it.
     * - Parameter requestExecutorType: The request executor type to use to execute the requests.
     * - Parameter downloadExecutorType: The download executor type to use to execute downloads.
     * - Parameter uploadExecutorType: The upload executor type to use to execute uploads
     */
    public init(
        baseURL: URL,
        requestInterceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor],
        encoder: JSONEncoder,
        decoder: JSONDecoder,
        requestExecutorType: RequestExecutorType = .async,
        downloadExecutorType: DownloadExecutorType = .default,
        uploadExecutorType: UploadExecutorType = .default
    ) {
        self.baseURL = baseURL
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
        self.encoder = encoder
        self.decoder = decoder
        self.requestExecutorType = requestExecutorType
        self.downloadExecutorType = downloadExecutorType
        self.uploadExecutorType = uploadExecutorType
    }
}
