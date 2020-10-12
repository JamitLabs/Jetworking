import Foundation

public final class HeaderFieldsRequestInterceptor: RequestInterceptor {
    private var headerFields: () -> [String: String]

    init(headerFields: @escaping @autoclosure (() -> [String: String])) {
        self.headerFields = headerFields
    }

    public func intercept(_ request: URLRequest) -> URLRequest {
        var mutatedRequest: URLRequest = request
        headerFields().forEach { key, value in
            mutatedRequest.addValue(value, forHTTPHeaderField: key)
        }

        return mutatedRequest
    }
}
