import Foundation

public struct ClientConfiguration {
    let baseURL: URL
    let authenticationMethod: AuthenticationMethod
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(
        baseURL: URL,
        authenticationMethod: AuthenticationMethod,
        encoder: JSONEncoder,
        decoder: JSONDecoder
    ) {
        self.baseURL = baseURL
        self.authenticationMethod = authenticationMethod
        self.encoder = encoder
        self.decoder = decoder
    }
}
