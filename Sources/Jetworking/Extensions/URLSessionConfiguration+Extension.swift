import Foundation

extension URLSessionConfiguration {
    class func background(
        withIdentifier identifier: String,
        andIsDiscretionaryFlag isDiscretionary: Bool,
        andConfiguration sessionConfiguration: URLSessionConfiguration
    ) -> URLSessionConfiguration {
        let configuration: URLSessionConfiguration = .background(withIdentifier: identifier)
        configuration.isDiscretionary = isDiscretionary

        if #available(iOS 11.0, OSX 10.13, *) {
            configuration.waitsForConnectivity = sessionConfiguration.waitsForConnectivity
        }

        if #available(iOS 13.0, OSX 10.15, *) {
            configuration.allowsConstrainedNetworkAccess = sessionConfiguration.allowsConstrainedNetworkAccess
            configuration.allowsExpensiveNetworkAccess = sessionConfiguration.allowsExpensiveNetworkAccess
            configuration.tlsMinimumSupportedProtocolVersion = sessionConfiguration.tlsMinimumSupportedProtocolVersion
            configuration.tlsMaximumSupportedProtocolVersion = sessionConfiguration.tlsMaximumSupportedProtocolVersion
        }

        configuration.allowsCellularAccess = sessionConfiguration.allowsCellularAccess
        configuration.requestCachePolicy = sessionConfiguration.requestCachePolicy
        configuration.timeoutIntervalForRequest = sessionConfiguration.timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = sessionConfiguration.timeoutIntervalForResource
        configuration.networkServiceType = sessionConfiguration.networkServiceType
        configuration.connectionProxyDictionary = sessionConfiguration.connectionProxyDictionary
        configuration.httpShouldUsePipelining = sessionConfiguration.httpShouldUsePipelining
        configuration.httpShouldSetCookies = sessionConfiguration.httpShouldSetCookies
        configuration.httpCookieAcceptPolicy = sessionConfiguration.httpCookieAcceptPolicy
        configuration.httpAdditionalHeaders = sessionConfiguration.httpAdditionalHeaders
        configuration.httpMaximumConnectionsPerHost = sessionConfiguration.httpMaximumConnectionsPerHost
        configuration.httpCookieStorage = sessionConfiguration.httpCookieStorage
        configuration.urlCredentialStorage = sessionConfiguration.urlCredentialStorage
        configuration.urlCache = sessionConfiguration.urlCache
        configuration.shouldUseExtendedBackgroundIdleMode = sessionConfiguration.shouldUseExtendedBackgroundIdleMode
        configuration.protocolClasses = sessionConfiguration.protocolClasses

        return configuration
    }
}
