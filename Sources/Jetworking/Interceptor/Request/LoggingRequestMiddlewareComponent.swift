import Foundation

public final class LoggingRequestMiddlewareComponent: RequestMiddlewareComponent {
    private struct Constants {
        static let loggingPrefix: String = "LoggingRequestMiddlewareComponent"
    }

    private var logLevel: LogLevel

    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }

    // TODO: Do we need to log something else? Do we only want to log verbose?
    public func process(request: URLRequest) -> URLRequest {
        switch logLevel {
        case .verbose:
            print("---------------------------------------------------------------")
            if let url = request.url {
                print("\(Constants.loggingPrefix): Logging the URL: \(url)")
            } else {
                print("\(Constants.loggingPrefix): The URL is nil.")
            }

            if let allHTTPHeaderFields = request.allHTTPHeaderFields {
                print("\(Constants.loggingPrefix): Logging all HTTP header fields: \(allHTTPHeaderFields)")
            } else {
                print("\(Constants.loggingPrefix): There are no HTTP header fields set.")
            }

            if let httpMethod = request.httpMethod {
                print("\(Constants.loggingPrefix): Logging the HTTP method: \(httpMethod)")
            } else {
                print("\(Constants.loggingPrefix): The http method is nil.")
            }

            // TODO: Find out how to generally log the request body
//            if let httpBody = request.httpBody {
//                let body = try? JSONDecoder().decode(Body.self, from: httpBody)
//                print("Logging the HTTP body: \(body)")
//            }

            print("---------------------------------------------------------------")

        case .none, .debug, .warning, .error:
            break
        }

        return request
    }
}
