import Foundation

enum AuthenticationMethod {
    case none
    case basicAuthentication(username: String, password: String)
    case bearerToken(token: String)
    case custom(headerKey: String, headerValue: String)
}
