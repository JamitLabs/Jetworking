import Foundation

public final class AuthenticationRequestMiddlewareComponent: RequestMiddlewareComponent {
    private var authenticationMethod: AuthenticationMethod

    public enum AuthenticationMethod {
        case none
        case basicAuthentication(username: String, password: String)
        case bearerToken(token: String)
        case custom(headerKey: String, headerValue: String)
    }

    init(authenticationMethod: AuthenticationMethod) {
        self.authenticationMethod = authenticationMethod
    }
    
    public func process(request: URLRequest) -> URLRequest {
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
        let authorizationHeaderKey: String = "Authorization"

        switch authenticationMethod {
        case .none:
            return nil

        case let .basicAuthentication(username, password):
            var authString: String = ""
            let credentialsString = "\(username):\(password)"
            if let credentialsData = credentialsString.data(using: .utf8) {
                let base64Credentials = credentialsData.base64EncodedString(options: [])
                authString = "Basic \(base64Credentials)"
            }

            return [authorizationHeaderKey: authString]

        case let .bearerToken(token):
            return [authorizationHeaderKey: "Bearer \(token)"]

        case let .custom(headerKey, headerValue):
            return [headerKey: headerValue]
        }
    }
}
