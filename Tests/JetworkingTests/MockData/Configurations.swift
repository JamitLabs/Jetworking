import Foundation
@testable import Jetworking

enum Configurations {
    static func `default`(_ requestExecutorType: RequestExecutorType = .async) -> Configuration {
        return .init(
            baseURL: URL(string: "https://postman-echo.com")!,
            interceptors: [
                AuthenticationRequestInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsRequestInterceptor(headerFields: HeaderFields.additional),
                LoggingInterceptor()
            ],
            requestExecutorType: requestExecutorType
        )
    }

    static func extendClientConfiguration(_ configuration: Configuration, with cache: URLCache) -> Configuration {
        return .init(
            baseURL: configuration.baseURL,
            interceptors: configuration.interceptors + [DefaultSessionCacheIntercepter()],
            encoder: configuration.encoder,
            decoder: configuration.decoder,
            requestExecutorType: configuration.requestExecutorType,
            cache: cache
        )
    }
}
