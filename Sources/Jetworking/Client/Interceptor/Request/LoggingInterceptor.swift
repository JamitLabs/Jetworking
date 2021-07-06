import Foundation

/// Implementation of a request interceptor which logs the request information.
public final class LoggingInterceptor: Interceptor {
    private var logger: Logger

    /**
     * # Summary
     * The initialiser for the `LoggingRequestInterceptor`
     *
     * - Parameter logger:
     *  The logger to be used to pass the request information to. Default value for the logger is the `DefaultLogger`.
     */
    public init(logger: Logger = DefaultLogger()) {
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

    /**
     * # Summary
     * Intercepting the response by taking its information and creating a message to be logged.
     *
     * - Parameter response:
     *  The response returned by the data task
     * - Parameter data:
     *  The data returned by the data task.
     * - Parameter error:
     *  The error returned by the data task.
     *
     * - Returns:
     * The intercepted response.
     */
    public func intercept(response: URLResponse?, data: Data?, error: Error?) -> URLResponse? {
        var message: String = "\(String(describing: self)):\n"

        if let url = response?.url {
            message.append("Request URL: \(url)\n")
        }

        if let httpResponse = response as? HTTPURLResponse {
            message.append("Status code: \(httpResponse.statusCode)\n")
            message.append("All HTTP header fields: \(httpResponse.allHeaderFields)\n")
        }

        if let body = data, let bodyString = String(data: body, encoding: .utf8) {
            message.append("HTTP Response Body: \(bodyString)")
        }

        if let error = error {
            message.append(error.localizedDescription)
        }

        logger.log(message)

        return response
    }
}
