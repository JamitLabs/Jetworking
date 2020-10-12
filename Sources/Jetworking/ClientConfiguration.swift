import Foundation

public struct ClientConfiguration {
    let baseURL: URL
    let requestMiddlewareComponents: [RequestMiddlewareComponent]
    let responseMiddlewareComponents: [ResponseMiddlewareComponent]
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(
        baseURL: URL,
        requestMiddlewareComponents: [RequestMiddlewareComponent],
        responseMiddlewareComponents: [ResponseMiddlewareComponent],
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.baseURL = baseURL
        self.requestMiddlewareComponents = requestMiddlewareComponents
        self.responseMiddlewareComponents = responseMiddlewareComponents
        self.encoder = encoder
        self.decoder = decoder
    }
}
