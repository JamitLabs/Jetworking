import Foundation

/// Implementation of a response interceptor which logs the response information.
public final class LoggingResponseInterceptor: ResponseInterceptor {
    private var logger: Logger

    /**
     * # Summary
     * The initialiser for the `LoggingResponseInterceptor`
     *
     * - Parameter logger:
     *  The logger to be used to pass the response information to. Default value for the logger is the `DefaultLogger`.
     */
    public init(logger: Logger = DefaultLogger()) {
        self.logger = logger
    }

    /**
     * # Summary
     * Intercepting the response by taking its information and creating a message to be logged.
     *
     * - Parameter data:
     *  The data returned by the data task.
     * - Parameter response:
     *  The response returned by the data task
     * - Parameter error:
     *  The error returned by the data task.
     *
     * - Returns:
     * The intercepted response.
     */
    public func intercept(data: Data?, response: URLResponse?, error: Error?) -> URLResponse? {
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
