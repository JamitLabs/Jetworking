import Foundation

// NOTE: Extension to use URL as static base URL provider
extension URL: BaseURLProvider {
    public var baseURL: URL { self }
}
