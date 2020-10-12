import Foundation

public protocol RequestInterceptor {
    func intercept(_ request: URLRequest) -> URLRequest
}
