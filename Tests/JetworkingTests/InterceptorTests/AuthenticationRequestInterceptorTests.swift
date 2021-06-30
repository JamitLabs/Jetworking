import XCTest
@testable import Jetworking

final class AuthenticationRequestInterceptorTests: XCTestCase {
    func testAuthenticationMethodNone() {
        let authenticationRequestInterceptor: AuthenticationRequestInterceptor = .init(authenticationMethod: .none)

        var request: URLRequest = .init(url: URL(string: "https://www.google.com")!)
        request = authenticationRequestInterceptor.intercept(request)

        XCTAssertTrue(request.allHTTPHeaderFields == nil)
    }

    func testAuthenticationMethodBasicAuthentication() {
        let authenticationRequestInterceptor: AuthenticationRequestInterceptor = .init(authenticationMethod: .basicAuthentication(username: "username", password: "password"))

        var request: URLRequest = .init(url: URL(string: "https://www.google.com")!)
        request = authenticationRequestInterceptor.intercept(request)

        guard let headerFields = request.allHTTPHeaderFields else { return XCTFail("Header field for basic authentication not found.") }

        XCTAssertTrue((headerFields.contains(where: { $0.key == "Authorization" && $0.value == "Basic dXNlcm5hbWU6cGFzc3dvcmQ=" })))
    }

    func testAuthenticationMethodBearerToken() {
        let authenticationRequestInterceptor: AuthenticationRequestInterceptor = .init(authenticationMethod: .bearerToken(token: "token"))

        var request: URLRequest = .init(url: URL(string: "https://www.google.com")!)
        request = authenticationRequestInterceptor.intercept(request)

        guard let headerFields = request.allHTTPHeaderFields else { return XCTFail("Header field for bearer token authentication not found.") }

        XCTAssertTrue((headerFields.contains(where: { $0.key == "Authorization" && $0.value == "Bearer token" })))
    }

    func testAuthenticationMethodCustom() {
        let authenticationRequestInterceptor: AuthenticationRequestInterceptor = .init(
            authenticationMethod: .custom(headerKey: "CustomAuthorizationHeaderKey", headerValue: "CustomAuthorizationHeaderValue")
        )

        var request: URLRequest = .init(url: URL(string: "https://www.google.com")!)
        request = authenticationRequestInterceptor.intercept(request)

        guard let headerFields = request.allHTTPHeaderFields else { return XCTFail("Header field for custom authentication not found.") }

        XCTAssertTrue((headerFields.contains(where: { $0.key == "CustomAuthorizationHeaderKey" && $0.value == "CustomAuthorizationHeaderValue" })))
    }
}
