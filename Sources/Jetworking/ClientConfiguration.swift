import Foundation

public struct ClientConfiguration {
    let baseURL: URL
    let requestInterceptors: [RequestInterceptor]
    let responseInterceptors: [ResponseInterceptor]
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(
        baseURL: URL,
        requestInterceptors: [RequestInterceptor],
        responseInterceptors: [ResponseInterceptor],
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.baseURL = baseURL
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
        self.encoder = encoder
        self.decoder = decoder
    }
}
