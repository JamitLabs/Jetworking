import Foundation

public struct Configuration {
    let baseURL: URL
    let requestInterceptors: [RequestInterceptor]
    let responseInterceptors: [ResponseInterceptor]
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    let queueRequests: Bool

    init(
        baseURL: URL,
        requestInterceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor],
        encoder: JSONEncoder,
        decoder: JSONDecoder,
        queueRequests: Bool = false
    ) {
        self.baseURL = baseURL
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
        self.encoder = encoder
        self.decoder = decoder
        self.queueRequests = queueRequests
    }
}
