import Foundation

extension URLRequest {
    init(url: URL, clientConfiguration: ClientConfiguration) {
        self = URLRequest(url: url)

        setAuthorizationHeader(forConfiguration: clientConfiguration)
    }

    private mutating func setAuthorizationHeader(forConfiguration clientConfiguration: ClientConfiguration) {
        if
            let authorizationHeader: [String: String] = getAuthorizationHeader(forConfiguration: clientConfiguration),
            let authorizationKey = authorizationHeader.keys.first,
            let authorizationValue = authorizationHeader.values.first
        {
            addValue(authorizationValue, forHTTPHeaderField: authorizationKey)
        }
    }

    private func getAuthorizationHeader(forConfiguration clientConfiguration: ClientConfiguration) -> [String: String]? {
        let authorizationHeaderKey: String = "Authorization"

        switch clientConfiguration.authenticationMethod {
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
