import Foundation

public final class HeaderFieldsRequestMiddlewareComponent: RequestMiddlewareComponent {
    private var headerFields: [String: String]

    init(headerFields: [String: String]) {
        self.headerFields = headerFields
    }

    public func process(request: URLRequest) -> URLRequest {
        var mutatedRequest: URLRequest = request
        headerFields.forEach { key, value in
            mutatedRequest.addValue(value, forHTTPHeaderField: key)
        }

        return mutatedRequest
    }
}
