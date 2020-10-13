import Foundation

public protocol ResponseInterceptor {
    func intercept(data: Data?, response: URLResponse?, error: Error?) -> URLResponse?
}
