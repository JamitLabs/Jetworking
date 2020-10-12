import Foundation

public protocol MiddlewareComponent {
    func process(request: URLRequest) -> URLRequest
}
