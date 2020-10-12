import Foundation

public protocol ResponseInterceptor {
    func intercept(_ response: URLResponse) -> URLResponse
}
