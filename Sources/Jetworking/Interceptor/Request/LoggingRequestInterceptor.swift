import Foundation

public final class LoggingRequestInterceptor: RequestInterceptor {
    private var logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

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
