import Foundation

// Implementation of a request interceptor which logs the request information.
public final class LoggingRequestInterceptor: RequestInterceptor {
    private var logger: Logger

    /**
     * # Summary
     * The initializer for the `LoggingRequestInterceptor`
     *
     * - Parameter logger:
     *  The logger to be used to pass the request information to. Default value for the logger is the `DefaultLogger`.
     */
    init(logger: Logger = DefaultLogger()) {
        self.logger = logger
    }

    /**
     * # Summary
     * Intercepting the request by taking its information and creating a message to be logged.
     *
     * - Parameter request:
     *  The request to be intercepted.
     *
     * - Returns:
     * The intercepted request.
     */
    public func intercept(_ request: URLRequest) -> URLRequest {
        var message: String = "\(String(describing: self)):\n"
        if let url = request.url {
            message.append("Request URL: \(url)\n")
        }

        if let allHTTPHeaderFields = request.allHTTPHeaderFields {
            message.append("All HTTP header fields: \(allHTTPHeaderFields)\n")
        }

        if let httpMethod = request.httpMethod {
            message.append("HTTP method: \(httpMethod)\n")
        }

        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            message.append("HTTP Body: \(bodyString)")
        }

        logger.log(message)

        return request
    }
}
