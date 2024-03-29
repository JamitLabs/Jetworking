// Copyright © 2022 Jamit Labs GmbH. All rights reserved.

import Foundation
import Jetworking

/// This is an example of an interceptor that can be used to override the request url.
public final class LinkOverrideInterceptor: Interceptor {
    // MARK: - Properties
    static let `default`: LinkOverrideInterceptor = .init()
    var overrideUrlString: String? = nil

    // MARK: - Methods
    public func intercept(_ request: URLRequest) -> URLRequest {
        if let overrideUrlString = overrideUrlString {
            var newRequest = request
            newRequest.url = URL(string: overrideUrlString)!
            self.overrideUrlString = nil

            return newRequest
        } else {
            return request
        }
    }
}
