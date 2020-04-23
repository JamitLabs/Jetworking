import Foundation

public struct ClientConfiguration {
    let baseURL: URL
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(
        baseURL: URL,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.baseURL = baseURL
        self.encoder = encoder
        self.decoder = decoder
    }
}
