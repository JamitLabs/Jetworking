import Foundation

final class RequestLoggingMiddlewareComponent: MiddlewareComponent {
    private var logLevel: LogLevel
    
    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }

    // TODO: Do we need to log something else? Do we only want to log verbose?
    func process(request: URLRequest) -> URLRequest {
        switch logLevel {
        case .verbose:
            print("---------------------------------------------------------------")
            if let url = request.url {
                print("Logging the URL: \(url)")
            } else {
                print("The URL is nil.")
            }

            if let allHTTPHeaderFields = request.allHTTPHeaderFields {
                print("Logging all HTTP header fields: \(allHTTPHeaderFields)")
            } else {
                print("There are no HTTP header fields set.")
            }

            if let httpMethod = request.httpMethod {
                print("Logging the HTTP method: \(httpMethod)")
            } else {
                print("The http method is nil.")
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
