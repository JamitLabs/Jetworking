import Foundation
@testable import Jetworking

enum Configurations {
    static func `default`(
        _ requestExecuterType: RequestExecuterType = .custom(MockExecuter.self),
        globalHeaderFields: [String: String] = HeaderFields.additional
    ) -> Configuration {
        return .init(
            baseURLProvider: URL(string: "https://www.jamitlabs.com/")!,
            interceptors: [
                AuthenticationInterceptor(
                    authenticationMethod: .basicAuthentication(username: "username", password: "password")
                ),
                HeaderFieldsInterceptor(headerFields: globalHeaderFields),
                LoggingInterceptor()
            ],
            requestExecuterType: requestExecuterType
        )
    }

    static func extendClientConfiguration(_ configuration: Configuration, with cache: URLCache) -> Configuration {
        return .init(
            baseURLProvider: configuration.baseURLProvider,
            interceptors: configuration.interceptors + [DefaultSessionCacheIntercepter()],
            encoder: configuration.encoder,
            decoder: configuration.decoder,
            requestExecuterType: configuration.requestExecuterType,
            cache: cache
        )
    }
}
