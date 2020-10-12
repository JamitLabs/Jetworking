import Foundation

extension URLRequest {
    init(url: URL, httpMethod: HTTPMethod) {
        self = URLRequest(url: url)

        self.httpMethod = httpMethod.rawValue
    }
}
