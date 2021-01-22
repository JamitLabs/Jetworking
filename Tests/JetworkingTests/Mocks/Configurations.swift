import Foundation
@testable import Jetworking

enum Configurations {
    static func `default`(_ requestExecutorType: RequestExecutorType = .custom(MockExecuter.self)) -> Configuration {
        return .init(
            baseURL: URL(string: "https://www.jamitlabs.com/")!,
            interceptors: [
                AuthenticationRequestInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsRequestInterceptor(headerFields: HeaderFields.additional),
                LoggingInterceptor()
            ],
            requestExecuterType: requestExecuterType
        )
    }

    static func extendClientConfiguration(_ configuration: Configuration, with cache: URLCache) -> Configuration {
        return .init(
            baseURL: configuration.baseURL,
            interceptors: configuration.interceptors + [DefaultSessionCacheIntercepter()],
            encoder: configuration.encoder,
            decoder: configuration.decoder,
            requestExecuterType: configuration.requestExecuterType,
            cache: cache
        )
    }
}
