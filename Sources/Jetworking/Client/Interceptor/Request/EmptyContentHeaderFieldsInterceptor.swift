import Foundation

/**
 * A request interceptor which sets specific header fields
 * which are required for a request with content empty.
 */
internal final class EmptyContentHeaderFieldsInterceptor: HeaderFieldsInterceptor {
    /**
     * # Summary
     * Static header fields for a request with empty content
     *
     * - Content-type:
     *   Content type must be given as `text/plain` which is compliant with empty content.
     *   Other type like `application/json` may cause an inconsistency issue
     *   because empty content is invalid json.
     *
     * - Content-length:
     *   `0` byte for empty content
     */
    private static let headerFieldsForEmptyContent = { () -> [String: String] in
        return [
            "Content-type": "text/plain",
            "Content-length": "0"
        ]
    }

    convenience init() {
        self.init(headerFields: Self.headerFieldsForEmptyContent())
    }

    override public func intercept(_ request: URLRequest) -> URLRequest {
        var mutatedRequest: URLRequest = request

        // Repalce related header fields with the corresponding values
        headerFields().forEach { key, value in
            mutatedRequest.setValue(value, forHTTPHeaderField: key)
        }

        return mutatedRequest
    }
}
