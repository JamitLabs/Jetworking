import Foundation

public extension URLRequest {
    init(url: URL, httpMethod: HTTPMethod, httpBody: Data? = nil) {
        self = URLRequest(url: url)

        self.httpMethod = httpMethod.rawValue
        self.httpBody = httpBody
    }
}
