import Foundation

public final class AuthenticationRequestInterceptor: RequestInterceptor {
    private struct Constants {
        static let authorizationHeaderKey: String = "Authorization"
        static let basicAuthStringPrefix: String = "Basic"
        static let bearerAuthStringPrefix: String = "Bearer"
    }

    public enum AuthenticationMethod {
        case none
        case basicAuthentication(username: String, password: String)
        case bearerToken(token: String)
        case custom(headerKey: String, headerValue: String)
    }

    private var authenticationMethod: () -> AuthenticationMethod

    init(authenticationMethod: @escaping @autoclosure (() -> AuthenticationMethod)) {
        self.authenticationMethod = authenticationMethod
    }
    
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
