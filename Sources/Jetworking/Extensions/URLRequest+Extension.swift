import Foundation

extension URLRequest {
    init(url: URL, httpMethod: HTTPMethod, headerFields: [String: String]? = nil) {
        self = URLRequest(url: url)

        self.httpMethod = httpMethod.rawValue
        setHeaderFieldsIfNeeded(headerFields)
    }

    private mutating func setHeaderFieldsIfNeeded(_ headerFields: [String: String]?) {
        guard let headerFields = headerFields else { return }

        headerFields.forEach { key, value in
            addValue(value, forHTTPHeaderField: key)
        }
    }
}
