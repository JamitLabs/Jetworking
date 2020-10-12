import Foundation

final class HeaderFieldsMiddlewareComponent: MiddlewareComponent {
    private var headerFields: [String: String]

    init(headerFields: [String: String]) {
        self.headerFields = headerFields
    }

    func process(request: URLRequest) -> URLRequest {
        var mutatedRequest: URLRequest = request
        headerFields.forEach { key, value in
            mutatedRequest.addValue(value, forHTTPHeaderField: key)
        }

        return mutatedRequest
    }
}
