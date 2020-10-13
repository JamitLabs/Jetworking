import Foundation

public final class LoggingResponseInterceptor: ResponseInterceptor {
    private var logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }
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
