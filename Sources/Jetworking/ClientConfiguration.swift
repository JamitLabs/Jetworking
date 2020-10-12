import Foundation

public struct ClientConfiguration {
    let baseURL: URL
    let middlewareComponents: [MiddlewareComponent]
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(
        baseURL: URL,
        middlewareComponents: [MiddlewareComponent],
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.baseURL = baseURL
        self.middlewareComponents = middlewareComponents
        self.encoder = encoder
        self.decoder = decoder
    }
}
