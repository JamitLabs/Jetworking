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
}
