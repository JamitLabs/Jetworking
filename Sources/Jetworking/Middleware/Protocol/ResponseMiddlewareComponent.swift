import Foundation

public protocol ResponseMiddlewareComponent {
    func process(response: URLResponse) -> URLResponse
}
