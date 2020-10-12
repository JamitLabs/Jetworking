import Foundation

public final class LoggingRepsonseMiddlewareComponent: ResponseMiddlewareComponent {
    private struct Constants {
        static let loggingPrefix: String = "LoggingRepsonseMiddlewareComponent"
    }

    private var logLevel: LogLevel

    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }

    public func process(response: URLResponse) -> URLResponse {
        switch logLevel {
        case .verbose:
            print("---------------------------------------------------------------")
            if let url = response.url {
                print("\(Constants.loggingPrefix): Logging the URL: \(url)")
            } else {
                print("\(Constants.loggingPrefix): The URL is nil.")
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("\(Constants.loggingPrefix): Logging the status code: \(httpResponse.statusCode)")
                print("\(Constants.loggingPrefix): Logging all HTTP header fields: \(httpResponse.allHeaderFields)")
            }

            print("---------------------------------------------------------------")

        case .none, .debug, .warning, .error:
            break
        }

        return response
    }
}
