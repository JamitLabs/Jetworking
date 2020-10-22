import Foundation

/// Implementation of a request interceptor which handles authentication.
/// Currently there are four different authentication methods provided which are `none`, `basicAuthentication`, `bearerToken` and `custom`.
/// To be able to be highly flexible to also being able to switch between authentication methods, we provided the possibility to pass in an `autoclosure`
/// which is evaluated when this request is being intercepted.
public final class AuthenticationRequestInterceptor: RequestInterceptor {
    private struct Constants {
        static let authorizationHeaderKey: String = "Authorization"
        static let basicAuthStringPrefix: String = "Basic"
        static let bearerAuthStringPrefix: String = "Bearer"
    }

    /// The authentication methods currently supported.
    public enum AuthenticationMethod {
        case none
        case basicAuthentication(username: String, password: String)
        case bearerToken(token: String)
        case custom(headerKey: String, headerValue: String)
    }

    private var authenticationMethod: () -> AuthenticationMethod

    /**
     * # Summary
     * The initialiser for the `AuthenticationRequestInterceptor`
     *
     * - Parameter authenticationMethod:
     *  Either pass in an enum case or an `autoclosure` which then returns an `AuthenticationMethod`
     */
    public init(authenticationMethod: @escaping @autoclosure (() -> AuthenticationMethod)) {
        self.authenticationMethod = authenticationMethod
    }
    
    /**
     * # Summary
     *  Intercepting the request by adding the authentication header according to the given authentication metod.
     *  - When choosing `none` as authentication method nothing will be added to the request.
     *  - When choosing `basicAuthentication` a base 64 encoded string from the given username and password will be generated and added to the header fields of the request.
     *  - When choosing `bearerToken` the given token will be added to the header fields of the request.
     *  - When choosing `custom` the given header field key and header field value will be added to the header fields of the request.
     *
     * - Parameter request:
     *  The request to be intercepted.
     *
     * - Returns:
     *  The intercepted request.
     */
    public func intercept(_ request: URLRequest) -> URLRequest {
        var mutatedRequest: URLRequest = request
        if
            let authorizationHeader: [String: String] = getAuthorizationHeader(),
            let authorizationKey = authorizationHeader.keys.first,
            let authorizationValue = authorizationHeader.values.first
        {
            mutatedRequest.addValue(authorizationValue, forHTTPHeaderField: authorizationKey)
        }

        return mutatedRequest
    }

    private func getAuthorizationHeader() -> [String: String]? {
        switch authenticationMethod() {
        case .none:
            return nil

        case let .basicAuthentication(username, password):
            let credentialsString = "\(username):\(password)"
            guard let credentialsData = credentialsString.data(using: .utf8) else { return nil }

            let base64Credentials = credentialsData.base64EncodedString(options: [])
            let authString = "\(Constants.basicAuthStringPrefix) \(base64Credentials)"
            return [Constants.authorizationHeaderKey: authString]

        case let .bearerToken(token):
            return [Constants.authorizationHeaderKey: "\(Constants.bearerAuthStringPrefix) \(token)"]

        case let .custom(headerKey, headerValue):
            return [headerKey: headerValue]
        }
    }
}
