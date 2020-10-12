import Foundation

public protocol RequestMiddlewareComponent {
    func process(request: URLRequest) -> URLRequest
}
